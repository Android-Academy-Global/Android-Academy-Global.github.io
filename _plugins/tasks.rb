require "achievements"

include Achievements

module Tasks

  class TasksCollector < Jekyll::Generator
    def generate(site)
      tasksIndex = site.pages.detect {|page| page.path == "tasks/index.html" }
      tasks = site.pages.select {|page| 
        page.path.start_with?("tasks") && page.path != "tasks/index.html" && page.path != "tasks/template.md"
      }.map { |page|
        page.data["layout"] = "task"
        { 
          "authorTelegramName" => page.data["author"], 
          "title" => page.data["title"],
          "file" => page.basename
        }
      }
      tasksIndex.data["tasks"] = tasks
    end

  end

end