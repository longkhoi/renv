#!/usr/bin/env bash

renv() {
  case "$1" in
    status | s)
      [[ -n "$GEM_HOME" ]] && echo "GEM_HOME='$GEM_HOME'"
      [[ -n "$GEM_PATH" ]] && echo "GEM_PATH='$GEM_PATH'"
      echo "PATH='$PATH'" && return
      ;;
    reset | r)
      if [[ -z "$RENV_ORIG_PATH" ]]; then
        echo ">>>> renv not set. Try: \`renv'"
        return 3
      fi

      if [[ -n "$RENV_ORIG_GEM_HOME" ]]; then
        GEM_HOME=$RENV_ORIG_GEM_HOME
      else
        unset GEM_HOME
      fi
      if [[ -n "$RENV_ORIG_GEM_PATH" ]]; then
        GEM_PATH=$RENV_ORIG_GEM_PATH
      else
        unset GEM_PATH
      fi
      if [[ -n "$RENV_ORIG_PATH" ]]; then
        PATH=$RENV_ORIG_PATH
      fi
      unset RENV_ORIG_GEM_HOME RENV_ORIG_GEM_PATH RENV_ORIG_PATH

      echo "---> renv is reset, GEM_HOME is ${GEM_HOME:-<unset>}"
      ;;
    "")
      if [[ -n "$RENV_ORIG_PATH" ]]; then
        echo ">>>> renv already set, GEM_HOME is $GEM_HOME. Try: \`renv reset'"
        return 9
      fi

      eval "$(
        ruby -rrubygems - <<-'EOF'
      puts "local ruby_engine=#{defined?(RUBY_ENGINE) ? RUBY_ENGINE : 'ruby'}"
      puts "local ruby_version=#{RUBY_VERSION}"
      puts "local gem_path='#{Gem.path.join(':')}'"
EOF
      )"
      local gem_dir="$PWD/.gem/$ruby_engine/$ruby_version"

      export RENV_ORIG_PATH="$PATH"
      export RENV_ORIG_GEM_HOME="$GEM_HOME"
      export RENV_ORIG_GEM_PATH="$GEM_PATH"

      export PATH="$gem_dir/bin:$PATH"
      export GEM_HOME="$gem_dir"
      export GEM_PATH="$gem_dir:$gem_path"

      echo "---> renv is set, GEM_HOME is $GEM_HOME"
      ;;
    help | h | usage | --help | -h | *)
      echo "usage: renv [reset|status]"
      return
      ;;
  esac
}
