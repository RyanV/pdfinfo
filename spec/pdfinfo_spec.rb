require 'spec_helper'

RSpec.describe Pdfinfo do
  let(:pdf_path) { fixture_path('pdfs/test.pdf') }
  let(:pdfinfo) { described_class.new(pdf_path) }
  let(:encrypted_response) { File.read(fixture_path('shell_responses/encrypted.txt')).chomp }
  let(:unencrypted_response) { File.read(fixture_path('shell_responses/test.txt')).chomp }
  let(:mock_response) { unencrypted_response }


  def modified_response(response, key, new_value = '')
    response.sub(/(?<=#{key}:)(.+)$/, new_value)
  end

  specify "mock responses match" do
    expect(`pdfinfo -upw foo #{fixture_path('pdfs/encrypted.pdf')}`.chomp).to eq(encrypted_response)
    expect(`pdfinfo #{fixture_path('pdfs/test.pdf')}`.chomp).to eq(unencrypted_response)
  end

  before(:each) do
    allow(Open3).to receive(:capture2e).and_return([mock_response, nil, nil])
  end

  describe '.pdfinfo_command' do
    it "falls back to pdfinfo" do
      Pdfinfo.pdfinfo_command = nil
      expect(Pdfinfo.pdfinfo_command).to eq('pdfinfo')
    end

    it 'allows the command to be changed' do
      Pdfinfo.pdfinfo_command = '/another/bin/path/pdfinfo'
      expect(Pdfinfo.pdfinfo_command).to eq('/another/bin/path/pdfinfo')
    end
  end

  describe '.exec' do
    context 'with no options given' do
      it 'runs the pdfinfo command without flags' do
        expect(Open3).to receive(:capture2e).with("pdfinfo  path/to/file.pdf")
        Pdfinfo.new("path/to/file.pdf")
      end
    end

    context "passing in :user_password" do
      it 'runs the pdfinfo command passing the user password flag' do
        expect(Open3).to receive(:capture2e).with("pdfinfo -upw foo path/to/file.pdf")
        Pdfinfo.new("path/to/file.pdf", user_password: 'foo')
      end
    end
    context 'passing in :owner_password' do
      it 'runs the pdfinfo command passing the user password flag' do
        expect(Open3).to receive(:capture2e).with("pdfinfo -opw bar path/to/file.pdf")
        Pdfinfo.new("path/to/file.pdf", owner_password: 'bar')
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
      let(:mock_response) { modified_response(unencrypted_response, 'Title', '') }
      it 'returns nil' do
        expect(pdfinfo.title).to be_nil
      end
    end
  end

  describe '#subject' do
    context 'when given a subject' do
      it 'returns the subject' do
        expect(pdfinfo.subject).to eq('Pdfinfo Subject')
      end
    end
    context 'when title is not present' do
      let(:mock_response) { modified_response(unencrypted_response, 'Subject', '') }
      it 'returns nil' do
        expect(pdfinfo.subject).to be_nil
      end
    end
  end

  describe '#keywords' do
    context 'when given keywords' do
      it 'returns the keywords' do
        expect(pdfinfo.keywords).to eq(['Keyword1', 'Keyword2'])
      end
    end
    context 'when keywords is not present' do
      let(:mock_response) { modified_response(unencrypted_response, 'Keywords', '') }
      it 'returns an empty array' do
        expect(pdfinfo.keywords).to eq([])
      end
    end
  end

  describe '#author' do
    context 'when given an author' do
      it 'returns the author' do
        expect(pdfinfo.author).to eq('Pdfinfo Author')
      end
    end
    context 'when author is not present' do
      let(:mock_response) { modified_response(unencrypted_response, 'Author', '') }
      it 'returns nil' do
        expect(pdfinfo.author).to be_nil
      end
    end
  end

  describe '#creation_date' do
    context 'when given an author' do
      it 'returns a time object' do
        expect(pdfinfo.creation_date).to be_an_instance_of(Time)
      end
      it 'returns the time correctly parsed' do
        expect(pdfinfo.creation_date).to eq(Time.parse("2014-10-26 18:23:25 -0700"))
      end
    end
    context 'when creation date is not present' do
      let(:mock_response) { modified_response(unencrypted_response, 'CreationDate', '') }
      it 'returns nil' do
        expect(pdfinfo.creation_date).to be_nil
      end
    end
  end

  describe '#creator' do
    context 'when given a creator' do
      it { expect(pdfinfo.creator).to eq('Pdfinfo Creator') }
    end
    context 'when creator is not present' do
      let(:mock_response) { modified_response(unencrypted_response, 'Creator', '') }
      it { expect(pdfinfo.creator).to be_nil }
    end
  end

  describe '#producer' do
    context 'when given a creator' do
      it { expect(pdfinfo.producer).to eq('Pdfinfo Producer') }
    end
    context 'when creator is not present' do
      let(:mock_response) { modified_response(unencrypted_response, 'Producer', '') }
      it { expect(pdfinfo.producer).to be_nil }
    end
  end

  describe '#tagged?' do
    context 'when tagged' do
      let(:mock_response) { modified_response(unencrypted_response, 'Tagged', 'yes') }
      it { expect(pdfinfo.tagged?).to eq(true) }
    end
    context 'when not tagged' do
      let(:mock_response) { modified_response(unencrypted_response, 'Tagged', 'no') }
      it { expect(pdfinfo.tagged?).to eq(false) }
    end
  end

  describe '#form' do
    it { expect(pdfinfo.form).to eq('none') }
  end

  describe '#page_count' do
    it 'returns a fixnum value of the number of pages' do
      expect(pdfinfo.page_count).to eq(5)
    end
  end

  describe '#encrypted?' do
    context 'given encrypted pdf' do
      let(:mock_response) { encrypted_response }
      it { expect(pdfinfo.encrypted?).to eq(true) }
    end
    context 'given unencrypted pdf' do
      let(:mock_response) { unencrypted_response }
      it { expect(pdfinfo.encrypted?).to eq(false) }
    end
  end

  describe '#usage_rights' do
    context 'given encrypted pdf (all flags off)' do
      let(:mock_response) { encrypted_response }
      it 'returns a permissions hash' do
        expect(pdfinfo.usage_rights).to eq({
          print: false,
          copy: false,
          change: false,
          add_notes: false
        })
      end
    end
    context 'given unencrypted pdf' do
      let(:mock_response) { unencrypted_response }
      it 'returns a permissions hash' do
        expect(pdfinfo.usage_rights).to eq({
          print: true,
          copy: true,
          change: true,
          add_notes: true
        })
      end
    end
  end

  describe '#printable?' do
    context 'given a pdf that is printable' do
      let(:mock_response) { unencrypted_response }
      it { expect(pdfinfo.printable?).to eq(true) }
    end
    context 'given a pdf that is not printable' do
      let(:mock_response) { encrypted_response }
      it { expect(pdfinfo.printable?).to eq(false) }
    end
  end

  describe '#copyable?' do
    context 'given a pdf that is copyable' do
      let(:mock_response) { unencrypted_response }
      it { expect(pdfinfo.copyable?).to eq(true) }
    end
    context 'given a pdf that is not copyable' do
      let(:mock_response) { encrypted_response }
      it { expect(pdfinfo.copyable?).to eq(false) }
    end
  end

  describe '#changeable?' do
    context 'given a pdf that is changeable' do
      let(:mock_response) { unencrypted_response }
      it { expect(pdfinfo.changeable?).to eq(true) }
    end
    context 'given a pdf that is not changeable' do
      let(:mock_response) { encrypted_response }
      it { expect(pdfinfo.changeable?).to eq(false) }
    end
  end

  describe "#modifiable? (alias to changeable?)" do
    context 'given a pdf that is changeable' do
      let(:mock_response) { unencrypted_response }
      it { expect(pdfinfo.modifiable?).to eq(true) }
    end
    context 'given a pdf that is not changeable' do
      let(:mock_response) { encrypted_response }
      it { expect(pdfinfo.modifiable?).to eq(false) }
    end
  end

  describe '#annotatable?' do
    context 'given a pdf that is annotatable' do
      let(:mock_response) { unencrypted_response }
      it { expect(pdfinfo.annotatable?).to eq(true) }
    end
    context 'given a pdf that is not annotatable' do
      let(:mock_response) { encrypted_response }
      it { expect(pdfinfo.annotatable?).to eq(false) }
    end
  end

  describe '#width' do
    it { expect(pdfinfo.width).to eq(595.28) }
  end

  describe '#height' do
    it { expect(pdfinfo.height).to eq(841.89) }
  end

  describe '#size' do
    it 'returns a fixnm value for the file size in bytes' do
      expect(pdfinfo.file_size).to eq(2867)
    end
  end

  describe '#pdf_version' do
    it 'returns a string value for the PDF spec version' do
      expect(pdfinfo.pdf_version).to eq('1.3')
    end
  end
end