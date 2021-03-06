#   Copyright 2014 Vanderbilt University
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.


class RidersController < ApplicationController
  before_action :set_rider, only: [:show, :edit, :update, :destroy]
  helper_method :sort_column, :sort_direction
  
  # GET /riders
  # GET /riders.json
  def index
    if params[:search]
  		@riders = Rider.search(params[:search]).order("uuid asc")
  	elsif params[:sort] == "rides.length"
  		if sort_direction == "asc"
  			@riders = Rider.joins(:rides).group("rides.rider_id").order("count(rides.rider_id) asc")
  		else
  			@riders = Rider.joins(:rides).group("rides.rider_id").order("count(rides.rider_id) desc")
  		end
  	elsif params[:sort] == "ratings.length"
  		if sort_direction == "asc"
  			@riders = Rider.joins(:ratings).group("ratings.rider_id").order("count(ratings.rider_id) asc")
  		else
  			@riders = Rider.joins(:ratings).group("ratings.rider_id").order("count(ratings.rider_id) desc")
  		end  	
  	else
	    @riders = params[:sort] == nil ? Rider.all : Rider.order(sort_column + " " + sort_direction)
	end
  end

  # GET /riders/1
  # GET /riders/1.json
  def show
  end

  # Download CSV
  def download
      @riders = Document.all
      puts "Sending data as csv..."
      send_data @riders.as_csv, :filename => "riders.csv"
  end

  # Import CSV
  def import
      Rider.import(params[:file])
      redirect_to root_url, notice: "Riders imported."
  end

  # GET /riders/new
  def new
    @rider = Rider.new
  end

  # GET /riders/1/edit
  def edit
  end

  # POST /riders
  # POST /riders.json
  def create
    @rider = Rider.new(rider_params)

    respond_to do |format|
      if @rider.save
        format.html { redirect_to @rider, notice: 'Rider was successfully created.' }
        format.json { render action: 'show', status: :created, location: @rider }
      else
        format.html { render action: 'new' }
        format.json { render json: @rider.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /riders/1
  # PATCH/PUT /riders/1.json
  def update
    respond_to do |format|
      if @rider.update(rider_params)
        format.html { redirect_to @rider, notice: 'Rider was successfully updated.' }
        format.json { render action: 'show', status: :ok, location: @rider }
      else
        format.html { render action: 'edit' }
        format.json { render json: @rider.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /riders/1
  # DELETE /riders/1.json
  def destroy
    @rider.destroy
    respond_to do |format|
      format.html { redirect_to riders_url }
      format.json { head :no_content }
    end
  end

  def search
  	@riders = Rider.search(params[:search])
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_rider
      @rider = Rider.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def rider_params
      params.require(:rider).permit(:uuid)
    end
    
    def sort_column
    	if params[:sort] == "rides.length" || params[:sort] == "ratings.length"
    		params[:sort]
    	else
    		Rider.column_names.include?(params[:sort]) ? params[:sort] : "uuid"
    	end
    end

	def sort_direction
		%w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
	end
end
