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

  describe '#title' do
    context 'when given a title' do
      it 'returns the title' do
        expect(pdfinfo.title).to eq('Pdfinfo Title')
      end
    end
    context 'when title is not present' do
      it 'returns nil' do
        mocked_pdfinfo = modified_pdfinfo.call { |res| res.set('Title', nil) }
        expect(mocked_pdfinfo.title).to be_nil
      end
    end
  end

  describe '#subject' do
    context 'when given a subject' do
      subject { pdfinfo.subject }
      it { is_expected.to eq('Pdfinfo Subject') }
    end
    context 'when subject value is not present' do
      subject { modified_pdfinfo.call { |res| res.set('Subject', nil) }.subject }
      it { is_expected.to be_nil }
    end
    context 'when subject key is not present' do
      subject { modified_pdfinfo.call { |res| res.delete('Subject') }.subject }
      it { is_expected.to be_nil }
    end
  end

  describe '#keywords' do
    context 'when given keywords' do
      subject { pdfinfo.keywords }
      it { is_expected.to eq(%w(Keyword1 Keyword2)) }
    end
    context 'when keywords value is not present' do
      subject { modified_pdfinfo.call { |res| res.set('Keywords', '') }.keywords }
      it { is_expected.to eq([]) }
    end
    context 'when keywords key is not present' do
      subject { modified_pdfinfo.call { |res| res.delete('Keywords') }.keywords }
      it { is_expected.to eq([]) }
    end
  end

  describe '#author' do
    context 'when given an author' do
      subject { pdfinfo.author }
      it { is_expected.to eq('Pdfinfo Author') }
    end
    context 'when author is not present' do
      subject { modified_pdfinfo.call { |res| res.set('Author', '') }.author }
      it { is_expected.to be_nil }
    end
  end

  describe '#creation_date' do
    context 'when given an author' do
      subject { pdfinfo.creation_date }
      it { is_expected.to be_respond_to(:utc) }
      it 'returns the time correctly parsed' do
        is_expected.to be_monday
      end
    end
    context 'when creation date value is not present' do
      subject { modified_pdfinfo.call { |res| res.set('CreationDate', '') }.creation_date }
      it { is_expected.to be_nil }
    end
    context 'when creation date key is not present' do
      subject { modified_pdfinfo.call { |res| res.delete('CreationDate') }.creation_date }
      it { is_expected.to be_nil }
    end
  end

  describe '#modified_date' do
    let(:pdf_path) { fixture_path('pdfs/test.pdf') }
    subject { pdfinfo.modified_date }
    context 'when given a ModDate' do
      it { is_expected.to be_respond_to(:utc) }
      it 'returns the time correctly parsed' do
        expect(pdfinfo.modified_date).to be_wednesday
      end
    end
  end

  describe '#creator' do
    context 'when given a creator' do
      subject { pdfinfo.creator }
      it { is_expected.to eq('Pdfinfo Creator') }
    end
    context 'when creator value is not present' do
      subject { modified_pdfinfo.call { |res| res.set('Creator', '') }.creator }
      it { is_expected.to be_nil }
    end
    context 'when creator key is not present' do
      subject { modified_pdfinfo.call { |res| res.delete('Creator') }.creator }
      it { is_expected.to be_nil }
    end
  end

  describe '#producer' do
    context 'when given a creator' do
      subject { pdfinfo.producer }
      it { is_expected.to eq('Pdfinfo Producer') }
    end
    context 'when creator is not present' do
      subject { modified_pdfinfo.call { |res| res.set('Producer', '') }.producer }
      it { is_expected.to be_nil }
    end
  end

  describe '#tagged?' do
    context 'when tagged' do
      subject { modified_pdfinfo.call { |res| res.set('Tagged', 'yes') }.tagged? }
      it { is_expected.to eq(true) }
    end
    context 'when not tagged' do
      subject { modified_pdfinfo.call { |res| res.set('Tagged', 'no') }.tagged? }
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
    context 'given a pdf that is printable' do
      use_encrypted!
      subject do
        modified_pdfinfo.call do |res|
          res.set('Encrypted', 'yes (print:yes copy:no change:no addNotes:no)')
        end.printable?
      end
      it { is_expected.to eq(true) }
    end
    context 'given a pdf that is not printable' do
      use_encrypted!
      subject { pdfinfo.printable? }
      it { is_expected.to eq(false) }
    end
  end

  describe '#copyable?' do
    context 'given a pdf that is copyable' do
      subject { modified_pdfinfo.call { |res| res.set_encryption(true, copy: true) }.copyable? }
      it { is_expected.to eq(true) }
    end
    context 'given a pdf that is not copyable' do
      subject { modified_pdfinfo.call { |res| res.set_encryption(true, copy: false) }.copyable? }
      it { is_expected.to eq(false) }
    end
  end

  describe '#changeable?' do
    use_encrypted!
    context 'given a pdf that is changeable' do
      subject { modified_pdfinfo.call { |res| res.set_encryption(true, change: true) }.changeable? }
      it { is_expected.to eq(true) }
    end
    context 'given a pdf that is not changeable' do
      subject { modified_pdfinfo.call { |res| res.set_encryption(true, change: false) }.changeable? }
      it { is_expected.to eq(false) }
    end
  end

  describe '#modifiable? (alias to changeable?)' do
    context 'given a pdf that is changeable' do
      subject { modified_pdfinfo.call { |res| res.set_encryption(true, change: true) }.modifiable? }
      it { is_expected.to eq(true) }
    end
    context 'given a pdf that is not changeable' do
      subject { modified_pdfinfo.call { |res| res.set_encryption(true, change: false) }.modifiable? }
      it { is_expected.to eq(false) }
    end
  end

  describe '#annotatable?' do
    context 'given a pdf that is annotatable' do
      subject { modified_pdfinfo.call { |res| res.set_encryption(true, addNotes: true) }.annotatable? }
      it { is_expected.to eq(true) }
    end
    context 'given a pdf that is not annotatable' do
      subject { modified_pdfinfo.call { |res| res.set_encryption(true, addNotes: false) }.annotatable? }
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
        creation_date: Time.parse('2014-10-27 01:23:25 UTC'),
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
    context "when pdf has been optimized" do
      subject { modified_pdfinfo.call { |res| res.set('Optimized', 'yes') }.optimized? }
      it { is_expected.to eq(true) }
    end
    context "when pdf has not been optimized" do
      subject { modified_pdfinfo.call { |res| res.set('Optimized', 'no') }.optimized? }
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
        is_expected.to be_respond_to(:utc)
      end
    end

    context 'when given an invalid time format' do
      let(:time) { "ten o'clock" }
      it { is_expected.to be_nil }
    end
  end
end