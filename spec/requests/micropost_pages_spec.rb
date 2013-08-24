require 'spec_helper'

describe "Micropost pages" do

	subject { page }

	let(:user) { FactoryGirl.create(:user)  }
	before { sign_in user  }

	describe 'micropost creation' do
		
		before { visit root_path  }
		
		describe 'with invalid information' do

			it 'should not create a micrompost' do
				expect { click_button 'Post' }.not_to change(Micropost, :count)
			end	
			
			describe 'error messages' do
				before { click_button 'Post'  }
				it { should have_content('error')  }
			end
		end

		describe 'with valid information' do
			
			before { fill_in 'micropost_content', with: 'Lorem ipsum'  }
			it 'should create a micropost' do
				expect { click_button 'Post' }.to change(Micropost, :count).by(1)
			end
		end
	end

	describe 'micropost destruction' do

		describe 'delete links' do
			let(:another_user) { FactoryGirl.create(:user)  }
			let!(:m1) { FactoryGirl.create(:micropost, user: user)  }		
			let!(:m2) { FactoryGirl.create(:micropost, user: another_user)  }		
			before { visit root_path  }
		
			describe 'as correct user' do
				it { should have_link('delete', href: micropost_path(m1)) }
			end

			describe 'as incorrect user' do
				it { should_not have_link('delete', href: micropost_path(m2)) }
			end
		end
	
		describe 'as correct user' do
			let!(:micropost) { FactoryGirl.create(:micropost, user: user)  }		
			before { visit root_path  }
			it 'should delete a micropost' do
				expect { click_link 'delete' }.to change(Micropost, :count).by(-1)
			end
		end

	end

	describe 'in profile' do
		before { 100.times { FactoryGirl.create(:micropost, user: user) } }
		
		describe 'pagination' do
			before { visit user_path(user)  }

			it { should have_selector('div.pagination')  }	

			it 'should list each micropost' do
				user.microposts.paginate(page: 1).each do |micropost|
					page.should have_selector('li', text: micropost.content)
				end
			end

		end
	end
end
