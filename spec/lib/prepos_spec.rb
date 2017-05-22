require 'spec_helper'
require 'vcr_helper'

require_relative '../../lib/prepos.rb'

RSpec.describe PRepos do
  subject { described_class.run }

  let(:default_out) do <<~EOS
    Usage: prepos [options]
        -t, --gh-token TOKEN             Set Github token
        -a, --gh-author AUTHOR           Set Github author
        -r COMMA,SEPARATED,REPOS,        Set Github author's repos
            --gh-repos
        -p, --prettify                   Prettify JSON output (console only)
        -h, --help                       Print this help
    EOS
  end

  before do
    stub_const('ARGV', options.split)
  end

  context 'without any option' do
    let(:options) { '' }
    let(:expected_output) { '{"error":"Invalid argument(s), please use prepos --help."}' }

    it { expect { subject }.to output(expected_output).to_stdout }
  end

  context 'with valid Github options' do
    before do
      allow($stdout).to receive(:puts)
      allow($stdout).to receive(:print)
    end

    context 'with valid credentials' do
      before do
        VCR.use_cassette('github_valid_credentials') do
          @result = subject.to_json
        end
      end

      let(:options) { '-a your -r _repo -t VALID_TOKEN' }
      let(:expected_output) do
'{"pulls":[{"repo":"your/_repo","number":1,"title":"Test PR","body":"Nothing special.\n","approved":false,"mergeable":true}]}'
      end

      it { expect(@result).to eq(expected_output) }
    end

    context 'with invalid credentials' do
      before do
        VCR.use_cassette('github_invalid_credentials') do
          @result = subject.to_json
        end
      end

      let(:options) { '-a your -r _repo -t INVALID_TOKEN' }
      let(:expected_output) do
'{"error":"GET https://api.github.com/repos/your/_repo/issues?per_page=100: 401 - Bad credentials // See: https://developer.github.com/v3"}'
      end

      it { expect(@result).to eq(expected_output) }
    end

    context 'with -m option' do
      before do
        VCR.use_cassette('github_rules_min_approvals_1') do
          @result = subject.to_json
        end
      end

      let(:options) { '-a your -r _repo -t TOKEN -m 1' }
      let(:expected_output) do
'{"pulls":[{"repo":"your/_repo","number":1,"title":"Test PR","body":"Nothing special.\n","approved":true,"mergeable":true}]}'
      end

      it { expect(@result).to eq(expected_output) }
    end
  end

  context 'with option -h' do
    let(:options) { '-h' }
    let(:expected_output) do
      <<~EOS
      Usage: prepos [options]
          -t, --gh-token TOKEN             Set Github token
          -a, --gh-author AUTHOR           Set Github author
          -r COMMA,SEPARATED,REPOS,        Set Github author's repos
              --gh-repos
          -p, --prettify                   Prettify JSON output (console only)
          -h, --help                       Print this help
      EOS
    end

    it { expect { subject }.to output(expected_output).to_stdout }
  end
end
