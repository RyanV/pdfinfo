RSpec.describe Pdfinfo::Page do
  let(:page_string) { "Page    1 size: 595.28 x 841.89 pts (A4) (rotated 20 degrees)" }
  let(:page) { described_class.from_string(page_string) }
  subject { page }
  describe '.from_string' do
    it 'returns an instance of Pdfinfo::Page' do
      expect(subject).to be_instance_of(Pdfinfo::Page)
    end
    it 'parses the string correctly' do
      expect(Pdfinfo::Page).to receive(:new).with('1', '595.28', '841.89', '20')
      subject
    end
  end

  describe '#page_number' do
    subject { page.page_number }
    it { is_expected.to eq(1) }
  end

  describe '#height' do
    subject { page.height }
    it { is_expected.to eq(841.89) }
  end

  describe '#width' do
    subject { page.width }
    it { is_expected.to eq(595.28) }
  end

  describe '#rotation' do
    subject { page.rotation }
    it { is_expected.to eq(20.0) }
  end

  describe '#rotated?' do
    context 'given a rotated pdf' do
      let(:page_string) { "Page    1 size: 595.28 x 841.89 pts (A4) (rotated 20 degrees)" }
      it { is_expected.to be_rotated }
    end
    context 'given an un-rotated pdf' do
      let(:page_string) { "Page    1 size: 595.28 x 841.89 pts (A4) (rotated 0 degrees)" }
      it { is_expected.not_to be_rotated }
    end
  end

  describe "#to_hash" do
    it 'returns a hash representation of the object' do
      expect(subject.to_hash).to eq({page_number: 1, width: 595.28, height: 841.89, rotation: 20.0})
    end
  end
end