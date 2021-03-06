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

  it 'can delete first leaf node and add a node to its sibling' do
    to = AsciiTree.parse('
            (  a  )
            /     \
           b       c
            \     / \
             e   f   g
             |
             h
    ')

    operations = described_class.new(from: from, to: to)

    expect(operations.to_a).to eq [
      TreeDelta::Operation.new(
        type: :delete,
        identity: 'd'
      ),
      TreeDelta::Operation.new(
        type: :create,
        identity: 'h',
        parent: 'e',
        position: 0
      )
    ]
  end

  it 'can delete first non-leaf node, first leaf node of the 2nd non-leaf node and add a node to the last leaf node' do
    to = AsciiTree.parse('
            (  a  )
                  \
                   c
                    \
                     g
                     |
                     h
    ')

    operations = described_class.new(from: from, to: to)

    expect(operations.to_a).to eq [
      TreeDelta::Operation.new(
        type: :delete,
        identity: 'f'
      ),
      TreeDelta::Operation.new(
        type: :delete,
        identity: 'b'
      ),
      TreeDelta::Operation.new(
        type: :create,
        identity: 'h',
        parent: 'g',
        position: 0
      )
    ]
  end

  it 'can delete a non-leaf node and a add a leaf node to the root as middle child' do
    to = AsciiTree.parse('
            (  a  )
               |  \
               h   c
                  / \
                 f   g
    ')

    operations = described_class.new(from: from, to: to)

    expect(operations.to_a).to eq [
      TreeDelta::Operation.new(
        type: :delete,
        identity: 'b'
      ),
      TreeDelta::Operation.new(
        type: :create,
        identity: 'h',
        parent: 'a',
        position: 0
      )
    ]
  end

  it 'can delete a non-leaf node and a add a leaf node to the root as last child' do
    to = AsciiTree.parse('
            (  a  )
               |  \
               c   h
              / \
             f   g
    ')

    operations = described_class.new(from: from, to: to)

    expect(operations.to_a).to eq [
      TreeDelta::Operation.new(
        type: :delete,
        identity: 'b'
      ),
      TreeDelta::Operation.new(
        type: :create,
        identity: 'h',
        parent: 'a',
        position: 1
      )
    ]
  end
end
