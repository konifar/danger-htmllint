RSpec.describe 'Danger' do
  describe "with Dangerfile" do
    before do
      @dangerfile = testing_dangerfile
      @htmllint = @dangerfile.htmllint

      # stub
      allow(@htmllint).to receive(:htmllint_bin_path).and_return("./node_modules/.bin/htmllint")
      allow(@htmllint.git).to receive(:added_files).and_return([])
      allow(@htmllint.git).to receive(:modified_files).and_return([])
      allow(@htmllint.git).to receive(:deleted_files).and_return([])
    end

    describe ".parse" do
      subject(:errors) do
        @htmllint.send(:parse, fixture)
      end

      context "when result has 2 errors" do
        let(:fixture) do
          "app/index.html: line 1, col 1, tag names must be lowercase\nindex.html: line 592, col 1, indenting spaces must be used in groups of 2\n\n[htmllint] found 3 errors out of 62 files\n"
        end

        it "has 2 errors" do
          expect(errors.size).to eq(2)
        end

        it "is mapped to be valid hash on first item" do
          expected = {
              file_path: "app/index.html",
              line: 1,
              severity: "warn",
              message: "tag names must be lowercase (col:1)"
          }
          expect(errors[0]).to eq(expected)
        end

        context "with fail_on_error = true" do
          before do
            @htmllint.fail_on_error = true
          end

          it "is mapped to be fail severity" do
            expect(errors.all? { |error| error[:severity] == "fail" }).to be true
          end
        end
      end

      context "when result has no error" do
        let(:fixture) do
          ""
        end

        it "has 0 error" do
          expect(errors.size).to eq(0)
        end
      end
    end

    describe ".htmllint_command" do
      subject(:command) do
        @htmllint.send(:htmllint_command, "./node_modules/.bin/htmllint", target_files)
      end

      context "when target_files has 2 items" do
        let(:target_files) do
          %w(app/index.html index.html)
        end

        it "is correct command" do
          expect(command).to eq("./node_modules/.bin/htmllint app/index.html index.html")
        end
      end

      context "when target_files has nothing" do
        let(:target_files) do
          []
        end

        it "is correct command" do
          expect(command).to eq("./node_modules/.bin/htmllint ")
        end
      end

      context "when rc_path = .textlintrc" do
        before do
          @htmllint.rc_path = ".textlintrc"
        end

        let(:target_files) do
          %w(index.html)
        end

        it "is correct command" do
          expect(command).to eq("./node_modules/.bin/htmllint index.html --rc .textlintrc")
        end
      end
    end

    describe ".target_files" do
      subject(:targets) do
        @htmllint.send(:target_files)
      end

      context "when target_files are empty" do
        it "is empty" do
          expect(targets.size).to eq(0)
        end
      end

      context "when target_files have 2 html files" do
        before do
          allow(@htmllint.git).to receive(:modified_files).and_return(%w(index.html app/index.html))
        end

        it "has 2 items" do
          expect(targets.size).to eq(2)
        end
      end

      context "when target_files have yml file" do
        before do
          allow(@htmllint.git).to receive(:modified_files).and_return(%w(index.html config.yml))
        end

        it "has 1 items" do
          expect(targets.size).to eq(1)
        end
      end
    end
  end
end
