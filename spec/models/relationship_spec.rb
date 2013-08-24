require 'spec_helper'

describe Relationship do

	let(:follower) { FactoryGirl.create(:user) }
	let(:followed) { FactoryGirl.create(:user) }
	let(:relationship) { follower.relationships.build(followed: followed)  }

	subject { relationship }

	it { should be_valid  }

	describe 'follower methods' do
		it { should respond_to(:follower)  }
		it { should respond_to(:followed)  }
		its(:follower) { should == follower }
		its(:followed) { should == followed }
	end

	describe 'when followed is not present' do
		before { relationship.followed = nil  }
		it { should_not be_valid }
	end

	describe 'when follower is not present' do
		before { relationship.follower = nil  }
		it { should_not be_valid }
	end

end
