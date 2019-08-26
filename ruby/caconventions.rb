require "json"
require 'open3'

module CAConventions
    class CLI
        @summary = {}
        @commands = {
            rubocop: "rubocop --require #{__dir__ }/CoderAcademyFormatter.rb --format CoderAcademyFormatter",
            flay: "flay ."
        }
        
        def self.analyze
            run_rubocop
            run_flay
            @summary
        end

        private

        def self.run(cmd)
            stdout, stderr, status = Open3.capture3(cmd)
            stdout
        end

        def self.run_rubocop
            output = run(@commands[:rubocop])
            @summary = JSON.parse(output)
        end

        def self.run_flay
            output = run(@commands[:flay])
            identical_count = output.scan(/IDENTICAL code/).size
            similar_count = output.scan(/Similar code/).size

            @summary[:identical_count] = identical_count
            @summary[:similar_count] = similar_count
            @summary[:duplicate_code] = output
        end
    end
end

puts JSON.pretty_generate(CAConventions::CLI.analyze)