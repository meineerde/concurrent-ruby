require 'spec_helper'

share_examples_for Concurrent::Obligation do

  context '#state' do

    it 'is :pending when first created' do
      f = pending_subject
      f.state.should == :pending
      f.should be_pending
    end

    it 'is :fulfilled when the handler completes' do
      f = fulfilled_subject
      f.state.should == :fulfilled
      f.should be_fulfilled
    end

    it 'is :rejected when the handler raises an exception' do
      f = rejected_subject
      f.state.should == :rejected
      f.should be_rejected
    end
  end

  context '#value' do

    it 'blocks the caller when :pending and timeout is nil' do
      f = pending_subject
      f.value.should be_true
      f.should be_fulfilled
    end

    it 'returns nil when reaching the optional timeout value' do
      f = pending_subject
      f.value(0).should be_nil
      f.should be_pending
    end

    it 'returns immediately when timeout is zero' do
      Timeout.should_not_receive(:timeout).with(any_args())
      f = pending_subject
      f.value(0).should be_nil
      f.should be_pending
    end

    it 'returns the value when fulfilled before timeout' do
      f = pending_subject
      f.value(10).should be_true
      f.should be_fulfilled
    end

    it 'returns nil when timeout reached' do
      f = pending_subject
      f.value(0.1).should be_nil
      f.should be_pending
    end

    it 'is nil when :pending' do
      expected = pending_subject.value(0)
      expected.should be_nil
    end

    it 'is nil when :rejected' do
      expected = rejected_subject.value
      expected.should be_nil
    end

    it 'is set to the return value of the block when :fulfilled' do
      expected = fulfilled_subject.value
      expected.should eq fulfilled_value
    end
  end

  context '#reason' do

    it 'is nil when :pending' do
      pending_subject.reason.should be_nil
    end

    it 'is nil when :fulfilled' do
      fulfilled_subject.reason.should be_nil
    end

    it 'is set to error object of the exception when :rejected' do
      rejected_subject.reason.should be_a(Exception)
      rejected_subject.reason.to_s.should =~ /#{rejected_reason}/
    end
  end
end
