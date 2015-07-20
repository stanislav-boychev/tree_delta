require "spec_helper"

RSpec.describe TreeDelta::Traversal do
  subject do
    described_class.new(direction: direction, order: order)
  end

  let(:tree) do
    AsciiTree.parse('
            root
            /  \
           a    b
          / \    \
         c   d    e
    ')
  end

  let(:identities) { subject.traverse(tree).map(&:identity) }

  it "enumerates an empty array when given nil" do
    traversal = described_class.new(
      direction: :left_to_right,
      order:     :pre
    )

    enumerator = traversal.traverse(nil)

    expect(enumerator).to be_an(Enumerator)
    expect(enumerator.to_a).to eq []
  end

  describe "left-to-right" do
    let(:direction) { :left_to_right }

    describe "pre-order" do
      let(:order) { :pre }

      it "traverses in the correct order" do
        expect(identities).to eq ["root", "a", "c", "d", "b", "e"]
      end
    end

    describe "post-order" do
      let(:order) { :post }

      it "traverses in the correct order" do
        expect(identities).to eq ["c", "d", "a", "e", "b", "root"]
      end
    end
  end

  describe "right-to-left" do
    let(:direction) { :right_to_left }

    describe "pre-order" do
      let(:order) { :pre }

      it "traverses in the correct order" do
        expect(identities).to eq ["root", "b", "e", "a", "d", "c"]
      end
    end

    describe "post-order" do
      let(:order) { :post }

      it "traverses in the correct order" do
        expect(identities).to eq ["e", "b", "d", "c", "a", "root"]
      end
    end
  end

end
