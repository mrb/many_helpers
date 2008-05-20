class ActiveRecord::Base
  extend ManyHelpers
end

ActionController::Base.helper ManyHelpersHelpers