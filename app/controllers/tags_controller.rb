# frozen_string_literal: true

class TagsController < ApplicationController
  before_action :authenticate_admin!

  def index
    @tags = Tag.all
  end

  def show
    @tag = Tag.find(params[:id])
  end

  def new
    @tag = Tag.new
  end

  def edit
    @tag = Tag.find(params[:id])
  end

  def create
    @tag = Tag.new(tag_params)

    if @tag.save
      flash.notice = "#{@tag.name} tag created."
      redirect_to tags_url
    else
      render :new, status: :unprocessable_content
    end
  end

  def update
    @tag = Tag.find(params[:id])

    if @tag.update(tag_params)
      flash.notice = 'Tag was successfully updated.'
      redirect_to tags_url
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    @tag = Tag.find(params[:id])
    name = @tag.name
    @tag.destroy
    flash.notice = "#{name} tag successfully destroyed."

    redirect_to tags_url
  end

  private

  def tag_params
    params.require(:tag).permit(:group, :name)
  end

  def authenticate_admin!
    return if admin_signed_in?

    redirect_to root_path, alert: I18n.t('must_be_admin')
  end
end
