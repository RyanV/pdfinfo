require 'spec_helper'

RSpec.describe Pdfinfo do
  use_unencrypted!

  let(:mock_file_path) { "path/to/file.pdf" }

  describe '.pdfinfo_command' do
    subject { described_class.pdfinfo_command }

    context 'when no command is set' do
      precondition do
        expect(Pdfinfo.instance_variable_get(:@pdfinfo_command)).to eq(nil)
      end

      it "falls back to 'pdfinfo'" do
        is_expected.to eq('pdfinfo')
      end
    end

    context 'when value is overridden' do
      before { Pdfinfo.pdfinfo_command = '/another/bin/path/pdfinfo' }

      it 'uses the override command' do
        is_expected.to eq('/another/bin/path/pdfinfo')
      end
    end
  end

  describe '.pdfinfo_command?' do
    it 'checks if the set command exists' do
      begin
        Pdfinfo.pdfinfo_command = 'a_command_that_doesnt_exist'
        expect(Pdfinfo.pdfinfo_command?).to eq false
        Pdfinfo.pdfinfo_command = 'echo'
        expect(Pdfinfo.pdfinfo_command?).to eq true
      ensure
        Pdfinfo.pdfinfo_command = nil
      end
    end
  end

  describe '#exec' do
    let(:mock_status) { instance_double(Process::Status, :success? => true, :exitstatus => 0) }
    let(:mock_response) { [fixture_path('shell_responses/unencrypted.txt').read, mock_status] }
    let(:expected_command) { "pdfinfo -f 0 -l -1 -enc UTF-8 #{mock_file_path}" }

    def expect_command_will_run(cmd)
      expect(Open3).to receive(:capture2).with(cmd).and_return(mock_response)
    end

    context 'with no options given' do
      it 'runs the pdfinfo command without flags' do
        expect_command_will_run("pdfinfo -f 0 -l -1 -enc UTF-8 #{mock_file_path}")
        # expect(Open3).to receive(:capture2).with(expected_command).and_return([fixture_path('shell_responses/unencrypted.txt').read, nil])
        Pdfinfo.new(mock_file_path)
      end
    end

    context 'passing in :user_password' do
      it 'runs the pdfinfo command passing the user password flag' do
        expect_command_will_run("pdfinfo -f 0 -l -1 -enc UTF-8 -upw foo #{mock_file_path}")
        Pdfinfo.new(mock_file_path, user_password: 'foo')
      end
    end

    context 'passing in :owner_password' do
      it 'runs the pdfinfo command passing the user password flag' do
        expect_command_will_run("pdfinfo -f 0 -l -1 -enc UTF-8 -opw bar #{mock_file_path}")
        Pdfinfo.new(mock_file_path, owner_password: 'bar')
      end
    end

    context 'when passed a path with spaces' do
      it 'should escape the file path' do
        expect_command_will_run("pdfinfo -f 0 -l -1 -enc UTF-8 path/to/file\\ with\\ spaces.pdf")
        Pdfinfo.new("path/to/file with spaces.pdf")
      end
    end

    context 'when given a file with invalid UTF-8 metadata' do
      it 'should parse correctly' do
        expect { Pdfinfo.new(fixture_path('pdfs/invalid-utf8.pdf')) }.not_to raise_exception
      end
    end

    context 'when the pdfinfo command cant be found' do
      it 'raises an appropriate exception' do
        expect(Pdfinfo).to receive(:pdfinfo_command?) { false }
        expect { Pdfinfo.new(mock_file_path) }.to raise_error(Pdfinfo::CommandNotFound)
      end
    end

    context 'when Pdfinfo.config_path is present' do
      it 'runs the command passing the config flag' do
        expect_command_will_run("pdfinfo -f 0 -l -1 -enc UTF-8 -cfg path/to/.xpdfrc #{mock_file_path}")
        Pdfinfo.config_path = "path/to/.xpdfrc"
        Pdfinfo.new(mock_file_path)
        Pdfinfo.config_path = nil
      end
    end

    context 'when passed :config_path' do
      it 'runs the command passing the config flag' do
        expect_command_will_run("pdfinfo -f 0 -l -1 -enc UTF-8 -cfg path/to/.xpdfrc #{mock_file_path}")
        Pdfinfo.new(mock_file_path, config_path: "path/to/.xpdfrc")
      end
    end

    context "when command fails" do
      let(:mock_status) { instance_double(Process::Status, :success? => false, :exitstatus => 1) }
      it "raises Pdfinfo::CommandFailed" do
        expect_command_will_run("pdfinfo -f 0 -l -1 -enc UTF-8 #{mock_file_path}")
        expect { Pdfinfo.new(mock_file_path) }.to raise_error(Pdfinfo::CommandFailed)
      end
    end
  end

  describe '#title' do
    context 'when given a title' do
      it 'returns the title' do
        expect(pdfinfo.title).to eq('Pdfinfo Title')
      end
    end

    context 'when title is not present' do
      modify_pdfinfo_response {|res| res.set('Title', nil) }
      it 'returns nil' do
        expect(pdfinfo.title).to be_nil
      end
    end
  end

  describe '#subject' do
    subject { pdfinfo.subject }
    context 'when given a subject' do
      it { is_expected.to eq('Pdfinfo Subject') }
    end
    context 'when subject value is not present' do
      modify_pdfinfo_response {|res| res.set('Subject', nil) }
      it { is_expected.to be_nil }
    end
    context 'when subject key is not present' do
      modify_pdfinfo_response {|res| res.delete('Subject') }
      it { is_expected.to be_nil }
    end
  end

  describe '#keywords' do
    subject { pdfinfo.keywords }
    context 'when given keywords' do
      it { is_expected.to eq(%w(Keyword1 Keyword2)) }
    end
    context 'when keywords value is not present' do
      modify_pdfinfo_response {|res| res.set('Keywords', '') }
      it { is_expected.to eq([]) }
    end
    context 'when keywords key is not present' do
      modify_pdfinfo_response {|res| res.delete('Keywords') }
      it { is_expected.to eq([]) }
    end
  end

  describe '#author' do
    subject { pdfinfo.author }
    context 'when given an author' do
      it { is_expected.to eq('Pdfinfo Author') }
    end
    context 'when author is not present' do
      modify_pdfinfo_response {|res| res.set('Author', '') }
      it { is_expected.to be_nil }
    end
  end

  describe '#creation_date' do
    subject { pdfinfo.creation_date }

    context 'when given an author' do
      it { is_expected.to be_an_instance_of(DateTime) }
      it 'returns the time correctly parsed' do
        expect(pdfinfo.creation_date).to eq(DateTime.parse('2014-10-27 01:23:25'))
      end
    end

    context 'when creation date value is not present' do
      modify_pdfinfo_response {|res| res.set('CreationDate', '') }
      it { is_expected.to be_nil }
    end

    context 'when creation date key is not present' do
      modify_pdfinfo_response {|res| res.delete('CreationDate') }
      it { is_expected.to be_nil }
    end
  end

  describe '#modified_date' do
    let(:pdf_path) { fixture_path('pdfs/test.pdf') }
    subject { pdfinfo.modified_date }
    context 'when given a ModDate' do
      it { is_expected.to be_an_instance_of(DateTime) }
      it 'returns the time correctly parsed' do
        expect(pdfinfo.modified_date).to eq(Time.parse("2013-05-08 15:15:28 UTC").to_datetime)
      end
    end
  end

  describe '#creator' do
    subject { pdfinfo.creator }
    context 'when given a creator' do
      it { is_expected.to eq('Pdfinfo Creator') }
    end

    context 'when creator value is not present' do
      modify_pdfinfo_response {|res| res.set('Creator', '') }
      it { is_expected.to be_nil }
    end
    context 'when creator key is not present' do
      modify_pdfinfo_response {|res| res.delete('Creator') }
      it { is_expected.to be_nil }
    end
  end

  describe '#producer' do
    subject { pdfinfo.producer }
    context 'when given a creator' do
      it { is_expected.to eq('Pdfinfo Producer') }
    end
    context 'when creator is not present' do
      modify_pdfinfo_response {|res| res.set('Producer', '') }
      it { is_expected.to be_nil }
    end
  end

  describe '#tagged?' do
    subject { pdfinfo.tagged? }
    context 'when tagged' do
      modify_pdfinfo_response {|res| res.set('Tagged', 'yes') }
      it { is_expected.to eq(true) }
    end
    context 'when not tagged' do
      modify_pdfinfo_response {|res| res.set('Tagged', 'no') }
      it { is_expected.to eq(false) }
      it { expect(pdfinfo.tagged?).to eq(false) }
    end
  end

  describe '#form' do
    subject { pdfinfo.form }
    it { is_expected.to eq('none') }
  end

  describe '#page_count' do
    subject { pdfinfo.page_count }
    it { is_expected.to eq(5) }
  end

  describe '#encrypted?' do
    subject { pdfinfo.encrypted? }

    context 'given encrypted pdf' do
      use_encrypted!
      it { is_expected.to eq(true) }
    end

    context 'given unencrypted pdf' do
      use_unencrypted!
      it { is_expected.to eq(false) }
    end
  end

  describe '#usage_rights' do
    subject { pdfinfo.usage_rights }

    context 'given encrypted pdf (all flags off)' do
      use_encrypted!

      it 'returns a permissions hash' do
        is_expected.to eq({
          print: false,
          copy: false,
          change: false,
          add_notes: false
        })
      end
    end

    context 'given unencrypted pdf' do
      use_unencrypted!

      it 'returns a permissions hash' do
        is_expected.to eq({
          print: true,
          copy: true,
          change: true,
          add_notes: true
        })
      end
    end
  end

  describe '#printable?' do
    subject { pdfinfo.printable? }

    context 'given a pdf that is printable' do
      use_encrypted!
      modify_pdfinfo_response {|res| res.set('Encrypted', 'yes (print:yes copy:no change:no addNotes:no)') }
      it { is_expected.to eq(true) }
    end
    context 'given a pdf that is not printable' do
      use_encrypted!
      it { is_expected.to eq(false) }
    end
  end

  describe '#copyable?' do
    subject { pdfinfo.copyable? }

    context 'given a pdf that is copyable' do
      modify_pdfinfo_response {|res| res.set_encryption(true, copy: true) }
      it { is_expected.to eq(true) }
    end
    context 'given a pdf that is not copyable' do
      modify_pdfinfo_response {|res| res.set_encryption(true, copy: false) }
      it { is_expected.to eq(false) }
    end
  end

  describe '#changeable?' do
    use_encrypted!

    subject { pdfinfo.changeable? }

    context 'given a pdf that is changeable' do
      modify_pdfinfo_response {|res| res.set_encryption(true, change: true) }
      it { is_expected.to eq(true) }
    end

    context 'given a pdf that is not changeable' do
      modify_pdfinfo_response {|res| res.set_encryption(true, change: false) }
      it { is_expected.to eq(false) }
    end
  end

  describe '#modifiable? (alias to changeable?)' do
    subject { pdfinfo.modifiable? }

    context 'given a pdf that is changeable' do
      modify_pdfinfo_response {|res| res.set_encryption(true, change: true) }
      it { is_expected.to eq(true) }
    end

    context 'given a pdf that is not changeable' do
      modify_pdfinfo_response {|res| res.set_encryption(true, change: false)}
      it { is_expected.to eq(false) }
    end
  end

  describe '#annotatable?' do
    subject { pdfinfo.annotatable? }
    context 'given a pdf that is annotatable' do
      modify_pdfinfo_response {|res| res.set_encryption(true, addNotes: true)}
      it { is_expected.to eq(true) }
    end
    context 'given a pdf that is not annotatable' do
      modify_pdfinfo_response {|res| res.set_encryption(true, addNotes: false)}
      it { is_expected.to eq(false) }
    end
  end

  describe '#width' do
    subject { pdfinfo.width }
    it "refers to the first page width" do
      expect(subject).to eq(595.28)
    end
  end

  describe '#height' do
    subject { pdfinfo.height }
    it "refers to the first page height" do
      expect(subject).to eq(841.89)
    end
  end

  describe '#size' do
    it 'returns a fixnm value for the file size in bytes' do
      expect(pdfinfo.file_size).to be_a(Fixnum).and be_between(2800, 2900)
    end
  end

  describe '#pdf_version' do
    it 'returns a string value for the PDF spec version' do
      expect(pdfinfo.pdf_version).to eq('1.3')
    end
  end

  describe "converting object to hash" do
    let(:expected_hash) do
      {
        pages: [
          {width: 595.28, height: 841.89, rotation: 0.0},
          {width: 595.28, height: 841.89, rotation: 0.0},
          {width: 595.28, height: 841.89, rotation: 0.0},
          {width: 595.28, height: 841.89, rotation: 0.0},
          {width: 595.28, height: 841.89, rotation: 0.0},
        ],
        title: "Pdfinfo Title",
        subject: "Pdfinfo Subject",
        author: "Pdfinfo Author",
        creator: "Pdfinfo Creator",
        producer: "Pdfinfo Producer",
        tagged: false,
        encrypted: false,
        page_count: 5,
        file_size: 2867,
        form: "none",
        pdf_version: "1.3",
        optimized: false,
        keywords: ["Keyword1", "Keyword2"],
        creation_date: DateTime.parse('2014-10-27 01:23:25'),
        modified_date: nil,
        usage_rights: {
          print: true,
          copy: true,
          change: true,
          add_notes: true
        }
      }
    end

    %w(to_hash to_h).each do |hash_method|
      it "##{hash_method} returns a hash of the metadata" do
        expect(pdfinfo.send(hash_method)).to eq(expected_hash)
      end
    end
  end

  describe "optimized?" do
    subject { pdfinfo.optimized? }
    context "when pdf has been optimized" do
      modify_pdfinfo_response {|res| res.set('Optimized', 'yes') }
      it { is_expected.to eq(true) }
    end
    context "when pdf has not been optimized" do
      modify_pdfinfo_response {|res| res.set('Optimized', 'no') }
      it { is_expected.to eq(false) }
    end
  end

  describe "#pages" do
    subject { pdfinfo.pages }
    it 'returns an array Pdfinfo::Page' do
      expect(subject).to be_an(Array)
      expect(subject.size).to eq(5)
      expect(subject.all? {|p| p.is_a?(Pdfinfo::Page) }).to eq(true)
    end
  end

  describe '#parse_time' do
    subject { pdfinfo.send(:parse_time, time) }

    context 'when given a valid time format' do
      let(:time) { "Wed May  8 15:15:28 2013" }
      it 'returns a Time object' do
        is_expected.to be_an_instance_of(DateTime)
      end
    end

    context 'when given an invalid time format' do
      let(:time) { "ten o'clock" }
      it { is_expected.to be_nil }
    end
  end
end