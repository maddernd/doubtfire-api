class ProjectsController < ApplicationController
  before_filter :authenticate_user!

  def index
    @projects = Project.where(unit_role:  @user.unit_roles)
  end

  def show
    @project = Project.includes(tasks:  [:task_definition]).find(params[:id])
    authorize! :read, @project, message:  "You are not authorised to view Project ##{@project.id}"

    respond_to do |format|
      format.html {render action:  'show'}
      format.json { 
        render json: @project.to_json(
          include:  [
            {
              tasks:  {include:  {task_definition:  {:except=>[:updated_at, :created_at]}}, except:  [:updated_at, :created_at], methods:  [:weight, :status] }
            },
            unit:  {except:  [:updated_at, :created_at]}
          ],
          methods:  [:progress, :completed_tasks_weight, :total_task_weight, :assigned_tasks],
          except:  [:updated_at, :created_at]
        )
      }
    end
  end
end