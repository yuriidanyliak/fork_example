require_relative '../lib/pi_calculator'

describe ProcessForker::PiCalculator do
  subject { calculate }

  let(:instance) { described_class.new(output_stream) }
  let(:output_stream) { double }

  let(:processes_number) { 5 }
  let(:calculate) { instance.call(processes_number) }

  before { allow(output_stream).to receive(:puts).and_return(nil) }

  context 'with spy on fork' do
    before { allow(instance).to receive(:fork).and_call_original }

    it 'forks parent process and outputs PI value' do
      calculate

      expect(instance).to have_received(:fork).exactly(processes_number).times do |&block|
        block.call
        expect(output_stream).to have_received(:puts).at_least(1).with(3.1415924535897797)
      end
    end
  end

  context 'with spy on #waitpid method' do
    before { allow(Process).to receive(:waitpid).and_call_original }

    it 'waits for every process to finish' do
      calculate

      expect(Process).to have_received(:waitpid).exactly(processes_number).times
    end
  end

  it 'publish notification about termination to output stream' do
    calculate

    expect(output_stream).to have_received(:puts).once
                        .with('Successfully waited for child processes termination.')
  end

  it { is_expected.to be_nil }
end
