require 'spec_helper'

describe "Authentication" do

	subject { page }

	describe 'signin page ' do
		before { visit signin_path }

		it { should have_selector('h1', text: 'Sign in')  }
		it { should have_title('Sign in')  }
	end	

	describe 'signin' do
		
		before { visit signin_path }

		describe 'with invalid information' do
			before { click_button 'Sign in' }

			it { should have_title('Sign in')  }
			it { should have_error_message('Invalid')  }

			describe 'after visiting another page' do
				before { click_link 'Home' }
				it { should_not have_error_message }
			end
		end	

		describe 'with valid information' do
			let (:user) { FactoryGirl.create(:user)  }
			before  { sign_in(user) }
		
			it { should have_title(user.name) }
			it { should have_link('Users', href: users_path)  }
			it { should have_link('Profile', href: user_path(user))  }
			it { should have_link('Settings', href: edit_user_path(user))  }
			it { should have_link('Sign out', href: signout_path)  }
			it { should_not have_link('Sign in', href: signin_path)  }
		
			describe "followed by signout" do
        		before { click_link "Sign out" }
        		it { should have_link('Sign in') }
				it { should_not have_link('Profile', href: user_path(user))  }
				it { should_not have_link('Settings', href: edit_user_path(user))  }
     		end
		end
	end

	describe 'authorization' do
	
		describe 'for non-signed-in users' do
			let(:user) { FactoryGirl.create(:user)  }

			describe 'in the Users controller' do
			
				describe 'visiting the edit page' do
					before { visit edit_user_path(user)  }
					it { should have_title('Sign in')  }
				end

				describe 'submitting to the update action' do
					before { patch user_path(user) }
					specify { response.should redirect_to(signin_path)  }
				end
				
				describe 'visiting the user index' do
					before { visit users_path }
					it { should have_title('Sign in')  }
				end

				describe 'visiting the following page' do
					before { visit following_user_path(user)  }
					it { should have_title('Sign in')  }
				end

				describe 'visiting the followers page' do
					before { visit followers_user_path(user)  }
					it { should have_title('Sign in')  }
				end
			end

			describe 'when attempting to visit a protected page' do
				before { visit edit_user_path(user) }
				it { should have_title('Sign in')  }

				describe 'after signing in' do
					before { sign_in user }

					it 'should render the desired protected page' do
						page.should have_title('Edit user')
					end

					describe 'when signing in again' do
						before do 
							sign_out
							sign_in user
						end

						it 'should render the default (profile) page' do
							page.should have_title(user.name) 
						end
					end
				end

				describe 'after signing in without capybara' do
					before { sign_in user, no_capybara: true  }

					describe 'submitting a GET request to the Sessions#new action' do
						before { get signin_path } 
						specify { response.should redirect_to(root_path)  }
					end

					describe 'submitting a POST request to the Sessions#create action' do
						before { post sessions_path } 
						specify { response.should redirect_to(root_path)  }
					end

				end

			end

			describe 'in the Microposts controllder' do
				
				describe 'submiting to the create action' do
					before { post microposts_path  }
					specify { response.should redirect_to(signin_path)  }
				end

				describe 'submitting to the destroy action' do
					before { delete micropost_path(FactoryGirl.create(:micropost))  }
					specify { response.should redirect_to(signin_path)  }
				end
			end

			describe 'in the Relationships controller' do
				describe 'submitting to the create action' do
					before { post relationships_path  }
					specify { response.should redirect_to(signin_path)  }
				end

				describe 'submitting to the destory action' do
					before { delete relationship_path(1)  }
					specify { response.should redirect_to(signin_path)  }
				end
			end
		end

		describe 'as wrong user' do
			let(:user) { FactoryGirl.create(:user)  }
			let(:wrong_user) { FactoryGirl.create(:user, email: 'wrong@example.com')  }
			before { sign_in user, no_capybara: true }

			describe 'visiting Users#edit page' do
				before { visit edit_user_path(wrong_user) }
				it { should_not have_title('Edit user')  }
			end
		
			describe 'submitting a PUT request to the Users#update action' do
				before { patch user_path(wrong_user) }
				specify { response.status.should == 403 }
			end
		end
		
		describe 'as non-admin user' do
			let(:user) { FactoryGirl.create(:user) }
			let(:non_admin) { FactoryGirl.create(:user) }

			before { sign_in non_admin, no_capybara: true }

			describe 'submitting a DELETE request to the Users#destory action' do
				before { delete user_path(user) }
				specify { response.status.should == 403 }
			end
		end

		describe 'as an admin user' do
			let(:admin) { FactoryGirl.create(:admin) }

			before { sign_in admin, no_capybara: true }
		
			describe 'submitting a DELETE request to delete himself/herself' do
				before { delete user_path(admin) }
				specify { response.status.should == 403 }
			end	
		end

		describe 'as an incorrect user' do
			let(:user) { FactoryGirl.create(:user) }
			let(:incorrect_user) { FactoryGirl.create(:user) }
			let(:micropost) { FactoryGirl.create(:micropost, user: user)  }

			before { sign_in incorrect_user, no_capybara: true  }

			describe 'submitting a delete request to the Micropost#destory action' do
				before { delete micropost_path(micropost)  }
				specify { response.status.should == 403 }
			end
		end
	end
end
