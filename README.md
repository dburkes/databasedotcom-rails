# databasedotcom-rails

Convenience classes to make using the databasedotcom gem with Rails apps even easier

#Installation
    gem install databasedotcom-rails
or, if you use Bundler

    gem 'databasedotcom-rails'
  
# Usage

Include the `Databasedotcom::Rails::Controller` module into your RESTful controller, and be sure to call `YourModel.coerce_params` before you pass parameters submitted from an HTML form to your materialized Sobject.

    class UsersController < ApplicationController
      include Databasedotcom::Rails::Controller
      before_filter :load_user, :except => [:index, :new]
  
      def index
        @users = User.all
      end
  
      def show
      end
    
      def new
        @user = User.new
      end
  
      def create
        User.create User.coerce_params(params[:user])
        flash[:info] = "The user was created!"
        redirect_to users_path
      end
  
      def edit
      end
  
      def update
        @user.update_attributes User.coerce_params(params[:user])
        flash[:info] = "The user was updated!"
        redirect_to user_path(@user)
      end
  
      def destroy
        @user.delete
        flash[:info] = "The user was deleted!"
        redirect_to users_path
      end
  
      private
  
      def load_user
        @user = User.find(params[:id])
      end
    end

# License

databasedotcom-rails is released under the MIT License