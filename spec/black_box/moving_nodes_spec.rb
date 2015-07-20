require 'spec_helper'

RSpec.describe TreeDelta do
  let(:from) do
    AsciiTree.parse('
            (  a  )
            /     \
           b       c
          / \     / \
         d   e   f   g
    ')
  end

  it 'can change order of a leaf nodes' do
    to = AsciiTree.parse('
            (  a  )
            /     \
           b       c
          / \     / \
         d   e   g   f
    ')

    operations = described_class.new(from: from, to: to)

    expect(operations.to_a).to eq [
      TreeDelta::Operation.new(
        type: :detach,
        identity: 'g',
      ),
      TreeDelta::Operation.new(
        type: :attach,
        identity: 'g',
        parent: 'c',
        position: 0
      )
    ]
  end

  it 'can change order of a non-leaf nodes (change children)' do
    to = AsciiTree.parse('
            (  a  )
            /     \
           c       b
          / \     / \
         f   g   d   e
    ')


    operations = described_class.new(from: from, to: to)

    expect(operations.to_a).to eq [
      TreeDelta::Operation.new(
        type: :detach,
        identity: 'c'
      ),
      TreeDelta::Operation.new(
        type: :attach,
        identity: 'c',
        parent: 'a',
        position: 0
      )
    ]
  end

  it 'can change order of a non-leaf nodes (keep children)' do
    to = AsciiTree.parse('
            (  a  )
            /     \
           c       b
          / \     / \
         d   e   f   g
    ')


    operations = described_class.new(from: from, to: to)

    expect(operations.to_a).to eq [
      TreeDelta::Operation.new(
        type: :detach,
        identity: 'g'
      ),
      TreeDelta::Operation.new(
        type: :detach,
        identity: 'f'
      ),
      TreeDelta::Operation.new(
        type: :detach,
        identity: 'c'
      ),
      TreeDelta::Operation.new(
        type: :detach,
        identity: 'e'
      ),
      TreeDelta::Operation.new(
        type: :detach,
        identity: 'd'
      ),
      TreeDelta::Operation.new(
        type: :attach,
        identity: 'c',
        parent: 'a',
        position: 0
      ),
      TreeDelta::Operation.new(
        type: :attach,
        identity: 'd',
        parent: 'c',
        position: 0
      ),
      TreeDelta::Operation.new(
        type: :attach,
        identity: 'e',
        parent: 'c',
        position: 1
      ),
      TreeDelta::Operation.new(
        type: :attach,
        identity: 'f',
        parent: 'b',
        position: 0
      ),
      TreeDelta::Operation.new(
        type: :attach,
        identity: 'g',
        parent: 'b',
        position: 1
      )
    ]
  end

  it 'can change order of a leaf nodes with different parents' do
    to = AsciiTree.parse('
            (  a  )
            /     \
           b       c
          / \     / \
         d   f   e   g
    ')

    operations = described_class.new(from: from, to: to)

    expect(operations.to_a).to eq [
      TreeDelta::Operation.new(
        type: :detach,
        identity: 'f',
      ),
      TreeDelta::Operation.new(
        type: :detach,
        identity: 'e',
      ),
      TreeDelta::Operation.new(
        type: :attach,
        identity: 'f',
        parent: 'b',
        position: 1
      ),
      TreeDelta::Operation.new(
        type: :attach,
        identity: 'e',
        parent: 'c',
        position: 0
      )
    ]
  end

  it 'can move a leaf node to be the last sibling of its parent' do
    to = AsciiTree.parse('
            (  a  )
            /  |  \
           b   c   e
          /   / \
         d   f   g
    ')

    operations = described_class.new(from: from, to: to)

    expect(operations.to_a).to eq [
      TreeDelta::Operation.new(
        type: :detach,
        identity: 'e'
      ),
      TreeDelta::Operation.new(
        type: :attach,
        identity: 'e',
        parent: 'a',
        position: 2
      )
    ]
  end

  it 'can move a leaf node to be the middle sibling of its parent' do
    to = AsciiTree.parse('
            (  a  )
            /  |  \
           b   g   c
          / \     /
         d   e   f
    ')
    operations = described_class.new(from: from, to: to)

    expect(operations.to_a).to eq [
      TreeDelta::Operation.new(
        type: :detach,
        identity: 'g'
      ),
      TreeDelta::Operation.new(
        type: :attach,
        identity: 'g',
        parent: 'a',
        position: 1
      )
    ]
  end

  it 'can move a leaf node to be the root node' do
    to = AsciiTree.parse('
               g
               |
            (  a  )
            /     \
           b       c
          / \     /
         d   e   f
    ')

    operations = described_class.new(from: from, to: to)

    expect(operations.to_a).to eq [
      TreeDelta::Operation.new(
        type: :detach,
        identity: 'g'
      ),
      TreeDelta::Operation.new(
        type: :attach,
        identity: 'a',
        parent: 'g',
        position: 0
      )
    ]
  end

  it 'can move a leaf node to be the root node' do
    to = AsciiTree.parse('
            (  c  )
            /     \
           b       a
          / \     / \
         d   e   f   g
    ')

    operations = described_class.new(from: from, to: to)

    expect(operations.to_a).to eq [
      TreeDelta::Operation.new(
        type: :detach,
        identity: 'g'
      ),
      TreeDelta::Operation.new(
        type: :detach,
        identity: 'f'
      ),
      TreeDelta::Operation.new(
        type: :detach,
        identity: 'c'
      ),
      TreeDelta::Operation.new(
        type: :detach,
        identity: 'b'
      ),
      TreeDelta::Operation.new(
        type: :attach,
        identity: 'b',
        parent: 'c',
        position: 0
      ),
      TreeDelta::Operation.new(
        type: :attach,
        identity: 'a',
        parent: 'c',
        position: 1
      ),
      TreeDelta::Operation.new(
        type: :attach,
        identity: 'f',
        parent: 'a',
        position: 0
      ),
      TreeDelta::Operation.new(
        type: :attach,
        identity: 'g',
        parent: 'a',
        position: 1
      )
    ]
  end

  it 'can move a node with leaf nodes to be its parents sibling' do
    # need a different from tree for this scenario
    from = AsciiTree.parse('
            (  a  )
            /     \
           b       c
          / \     / \
         d   e   f   g
                    / \
                   h   i
    ')

    to = AsciiTree.parse('
            (     a     )
            /     |     \
           b      g      c
          / \    / \    /
         d   e  h   i  f


    ')

    operations = described_class.new(from: from, to: to)

    expect(operations.to_a).to eq [
      TreeDelta::Operation.new(
        type: :detach,
        identity: 'g',
      ),
      TreeDelta::Operation.new(
        type: :attach,
        identity: 'g',
        parent: 'a',
        position: 1
      )
    ]
  end
end
