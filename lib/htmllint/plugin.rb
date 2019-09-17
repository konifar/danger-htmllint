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
      raise "htmlslint not found in ./node_modules/.bin/htmllint" unless File.exist?(local)

      local
    end

    def htmllint_command(bin, target_files)
      command = "#{bin} #{target_files.join(' ')}"
      command << " --rc #{rc_path}" if rc_path
      p command
      command
    end

    def run_htmllint(bin, target_files)
      `#{htmllint_command(bin, target_files)}`
    end

    def target_files
      ((git.modified_files - git.deleted_files) + git.added_files)
    end

    def parse(result)
      p result
      list = []
      result.split("\n").each do |item|
        next if item == ""

        path_and_err = item.split(":")
        next if path_and_err.length < 2

        file_path = path_and_err.first

        line_col_err_msg = path_and_err.last.split(", ")
        line = line_col_err_msg[0].sub("line ", "").to_i
        col = line_col_err_msg[1].sub("col ", "")
        err_msg = line_col_err_msg[2]

        list << {
          file_path: file_path,
          line: line,
          severity: severity_level(fail_on_error),
          message: "#{err_msg} (col:#{col})"
        }
      end

      list
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
