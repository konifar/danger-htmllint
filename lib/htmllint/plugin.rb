# require "mkmf"
require "json"

module Danger
  # [Danger](http://danger.systems/ruby/) plugin depends on [htmllint-cli](https://github.com/htmllint/htmllint-cli/).
  #
  # @example Run htmllint and send violations as inline comment.
  #
  #          # Lint added and modified files only
  #          htmllint.lint
  #
  # @see  konifar/danger-htmllint
  # @tags lint, htmllint
  #
  class DangerHtmllint < Plugin
    # .htmllintrc path
    # @return [String]
    attr_accessor :rc_path

    # Set danger fail when errors are detected
    # @return [Bool]
    attr_accessor :fail_on_error

    # Execute htmllint and send comment
    # @return [void]
    def lint
      return if target_files.empty?

      result = run_htmllint(htmllint_bin_path, target_files)
      send_comment(parse(result))
    end

    private

    def htmllint_bin_path
      local = "./node_modules/.bin/htmllint"

      # NOTE: Danger using method_missing hack for parse 'warn', 'fail' in Dangerfile.
      # Same issue will occur 'message' when require 'mkmf'. Because 'mkmf' provide 'message' method.
      # Then, disable find executable htmllint until danger fix this issue.

      # File.exist?(local) ? local : find_executable("htmllint")
      raise "htmlslint not found in ./node_modules/.bin/htmllint" unless File.exist?(local)

      local
    end

    def run_htmllint(bin, target_files)
      command = "#{bin} #{target_files.join(' ')}"
      command << " --rc #{rc_path}" if rc_path
      `#{command}`
    end

    def target_files
      ((git.modified_files - git.deleted_files) + git.added_files)
    end

    def parse(result)
      dir = "#{Dir.pwd}/"

      result.split("\n").flat_map do | line |
        path_and_err = line.split(":")
        break if path_and_err.empty?

        file_path = path_and_err.first

        line_col_err_msg = path_and_err.last.split(",")
        line = line_col_err_msg[0].sub(" line ", "")
        col = line_col_err_msg[1].sub(" col ", "")
        err_msg = line_col_err_msg[2].sub(/^ /, "")

        {
          file_path: file_path,
          line: line,
          severity: severity_level(fail_on_error),
          message: "#{err_msg} (col:#{col})"
        }
      end
    end

    def severity_level(fail_on_error)
      fail_on_error ? "fail" : "warn"
    end

    def send_comment(errors)
      errors.each do |error|
        send(error[:severity], error[:message], file: error[:file_path], line: error[:line])
      end
    end
  end
end