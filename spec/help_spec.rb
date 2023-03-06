require 'spec_helper'

RSpec.describe "Showing help", :type => :aruba do
  include_context "messages"

  let(:help_text) do
    <<~EXPECTED
      Usage: llmk [OPTION]... [FILE]...

      Options:
        -c, --clean           Remove the temporary files such as aux and log files.
        -C, --clobber         Remove all generated files including final PDFs.
        -d CAT, --debug=CAT   Activate debug output restricted to CAT.
        -D, --debug           Activate all debug output (equal to "--debug=all").
        -h, --help            Print this help message.
        -n, --dry-run         Show what would have been executed.
        -q, --quiet           Suppress most messages.
        -s, --silent          Silence messages from called programs.
        -v, --verbose         Print additional information.
        -V, --version         Print the version number.

      Please report bugs to <https://github.com/wtsnjp/llmk/issues>.
    EXPECTED
  end

  context "with --help" do
    before(:each) { run_llmk "--help" }

    it do
      expect(stdout).to eq help_text
      expect(last_command_started).to be_successfully_executed
    end
  end

  context "with -h" do
    before(:each) { run_llmk "-h" }

    it do
      expect(stdout).to eq help_text
      expect(last_command_started).to be_successfully_executed
    end
  end
end
