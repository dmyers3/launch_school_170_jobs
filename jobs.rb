require "sinatra"
require "sinatra/reloader" if development?
require "sinatra/content_for"
require "tilt/erubis"
require "yaml"
require "bcrypt"
require "pry"

configure do
  enable :sessions
  set :session_secret, 'secretpassword'
end

helpers do
  def signed_in?
    session[:username]
  end
end

before do
  session[:users] ||= []
  session[:jobs] ||= []
  @users = session[:users]
  @jobs = session[:jobs]
end

def find_user
  @users.find { |user| user[:username] == session[:username] }[:user_id]
end

# Home page shows sign in form if not signed in; otherwise redirects to user's page
get "/" do
  if session[:username]
    redirect "/users/#{find_user}"
  else
    erb :index
  end
end

# Specific user page showing customized jobs and info on user
get "/users/:user_id" do
  erb :user
end

# Signs in user
post "/users/signin" do
  
end

# checks to make sure username does not exist in @users
def verify_username_uniqueness
  if @users.find { |user| user[:username] == params[:username] }
    session[:message] = "Username already exists. Please choose a different one."
    redirect "/register"
  end
end

# checks to make sure password and password_verification are the same
def verify_password
  if params[:password] != params[:verify_pw]
    session[:message] = "Passwords don't match. Please try again."
    redirect "/register"
  end
end

# finds highest user_id in @users array and increments by 1
def assign_new_id(array)
  array.empty? ? 1 : array.max { |user| user[:user_id] }[:user_id] + 1
end


# Registers user
post "/users/register" do
  verify_username_uniqueness
  verify_password
  user_id = assign_new_id(@users)
  user = { username: params[:username], 
           password: BCrypt::Password.create(params[:password]),
           user_id: user_id }
  session[:users] << user
  session[:username] = user[:username]
  session[:message] = "User successfully created!"
  redirect "/users/#{user[:user_id]}"
end



# Register form
get "/register" do
  erb :register
end

# New job form
get "/jobs/new" do
  erb :newjob
end

# Posts new job
post "/jobs" do
  job_id = assign_new_id(@jobs)
  job = { company: params[:company], title: params[:title], 
          description: params[:description], city: params[:city], 
          state: params[:state], job_id: job_id }
  session[:jobs] << job
  session[:message] = "Job successfully posted!"
  redirect "/"
end

get "/jobs/:job_id" do
  @job = @jobs.find { |job| job[:job_id] == params[:job_id].to_i }
  if @job.nil?
    session[:message] = "Invalid Job ID"
    redirect "/"
  end
  erb :job
end








