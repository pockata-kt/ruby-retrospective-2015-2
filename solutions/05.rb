require 'digest/sha1'

class ObjectStore
  attr_reader :branch

  def self.init(&block)
    ObjectStore.new(&block)
  end

  def initialize(&block)
    @branch = Branch.new
    @current_branch = @branch.current_branch
    @current_commit = {}
    @directory = @branch.branches

    self.instance_eval &block if block_given?
  end

  def add(name, object)
    @current_commit[name] = object
    message = "Added #{name} to stage."
    Result.new(true, message, object)
  end

  def commit(message)
    if @current_commit.empty?
      message = "Nothing to commit, working directory clean."
      Result.new(false, message, {})
    else
      date = Time.now
      hash = Digest::SHA1.hexdigest "#{date}#{message}"
      @directory[@current_branch][hash] = @current_commit
      commit_message = "#{message}\n\t#{@current_commit.size} objects changed"
      @current_commit = {}
      Result.new(true, commit_message, @directory[@current_branch][hash])
    end
  end
end



class Branch
  attr_accessor :branches, :current_branch

  def initialize()
    @branches = { "master" => {} }
    @current_branch = "master"
  end

  def create(branch_name)
    if @branches.member?(branch_name)
      message = "Branch #{branch_name} already exists."
      Result.new(false, message, {})
    else
      @branches[branch_name] = @branches[@current_branch]
      message = "Created branch #{branch_name}."
      Result.new(true, message, @branches[branch_name])
    end
  end

  def checkout(branch_name)
    if @branches.member?(branch_name)
      @current_branch = branch_name
      message = "Switched to branch #{branch_name}."
      Result.new(true, message, {})
    else
      message = "Branch #{branch_name} does not exist."
      Result.new(false, message, {})
    end
  end

  def remove(branch_name)
    if ! @branches.member?(branch_name)
      message = "Branch #{branch_name} does not exist."
      Result.new(false, message, {})
    elsif @current_branch == branch_name
      message = "Cannot remove current branch."
      Result.new(false, message, {})
    else
      @branches.delete(branch_name)
      message = "Removed branch #{branch_name}."
      Result.new(true, message, {})
    end
  end

  def list
    message = @branches.keys
                       .sort
                       .each.map do |value|
                         if value == @current_branch
                           "* #{value}"
                         else
                           "  #{value}"
                         end
                       end
                       .join("\n")
    Result.new(true, message, {})
  end
end


class Result
  attr_reader :message, :result

  def initialize(state, message, result)
    @state = state
    @message = message
    @result = result
  end

  def success?
    @state
  end

  def error?
    ! @state
  end
end
