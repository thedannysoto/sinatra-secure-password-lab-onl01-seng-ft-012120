require "./config/environment"
require "./app/models/user"
require 'pry'
class ApplicationController < Sinatra::Base

  configure do
    set :views, "app/views"
    enable :sessions
    set :session_secret, "password_security"
  end

  get "/" do
    erb :index
  end

  get "/signup" do
    erb :signup
  end

  post "/signup" do
    user = User.new(:username => params[:username], :password => params[:password])
    if user[:username].empty? || user[:password_digest] == nil
      redirect "/failure"
    end
    user.save
    redirect "/login"
  end

  get '/account' do
    if logged_in?
      @user = User.find(session[:user_id])
      erb :account
    else
      redirect "/failure"
    end 
  end


  get "/login" do
    erb :login
  end

  post "/login" do
    user = User.find_by(:username => params[:username])
    if user && user.authenticate(params[:password])
      session[:user_id] = user.id
      redirect "/account"
    else
      redirect "/failure"
    end
  end

  get "/failure" do
    erb :failure
  end

  get "/logout" do
    session.clear
    redirect "/"
  end

  get "/deposit" do
    if logged_in?
      @user = User.find(session[:user_id])
      erb :deposit
    else
      redirect "/failure"
    end 
  end

  post "/deposit" do
    @user = User.find(session[:user_id])
    if params[:amount].to_f > 0
      @user.balance += params[:amount].to_f
      @user.save
      redirect "/account"
    else 
      redirect "/failure"
    end
  end

  get "/withdrawal" do
    if logged_in?
      @user = User.find(session[:user_id])
      erb :withdrawal
    else
      redirect "/failure"
    end 
  end

  post "/withdrawal" do
    @user = User.find(session[:user_id])
    if params[:amount].to_f > 0 && params[:amount].to_f <= @user.balance
      @user.balance -= params[:amount].to_f
      @user.save
      redirect "/account"
    else 
      redirect "/failure"
    end
  end

  helpers do
    def logged_in?
      !!session[:user_id]
    end

    def current_user
      User.find(session[:user_id])
    end
  end

end
