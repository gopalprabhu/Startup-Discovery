class CompaniesController < ApplicationController
  
  include HTTParty
  
  def new
    @company = Company.new
    render :new
  end
  
  def create
    @company = Company.new(company_params)
    if @company.save
      redirect_to company_url(@company)
    else
      flash.now[:errors] = @company.errors.full_messages
      render :new
    end
  end
  
  def show
    company = Company.find(params[:id])
    @response = JSON.parse HTTParty.get("http://api.crunchbase.com/v/1/company/#{company.name}.js?api_key=#{ENV['CRUNCHBASE_API_KEY']}").response.body
    @crunchbase = Crunchbase::Company.get("#{company.name}")
    @angel = AngellistApi.startup_search(:slug => "#{company.name}")

    @compete = HTTParty.get("https://apps.compete.com/sites/#{ @angel.company_url.gsub("http://", "").gsub("https://", "")}/trended/uv/?apikey=#{ENV['COMPETE_API_KEY']}").response.body
    render :show
  end
  
  def index
    render :index
  end
  
  private
  
  def company_params
    params.require(:company).permit(:name)
  end
  
end
