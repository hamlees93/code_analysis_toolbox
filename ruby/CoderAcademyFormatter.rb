require "json"

class CoderAcademyFormatter < RuboCop::Formatter::BaseFormatter
    def initialize(output, options = {})
        super
        @output_hash = {
            target_file_count: 0,
            inspected_file_count: 0,
            methods_count: 0,
            classes_count: 0,
            gems_count: 0,
            style_errors_count: 0,
            layout_errors_count: 0,
            naming_errors_count: 0,
            code_errors_count: 0,
            code_errors: []
        }
    end

    def started(target_files)
        @output_hash[:target_file_count] = target_files.count
    end

    def finished(inspected_files)
        @output_hash[:inspected_file_count] = inspected_files.count
        output.write @output_hash.to_json
    end

    def file_finished(file, offenses)
        count_file_stats(file)
        return if offenses.empty? 
        count_offenses_stats(offenses)
    end

    def count_file_stats(file)
        content = File.read(file)

        methods_count = content.scan(/def /).size
        classes_count = content.scan(/class /).size
        gems_count = content.scan(/require /).size

        @output_hash[:methods_count] += methods_count
        @output_hash[:classes_count] += classes_count
        @output_hash[:gems_count] += gems_count
    end
    
    def count_offenses_stats(offenses)
        offenses.each do |offense|
            name = offense.cop_name

            case name
            when /^Style/
                @output_hash[:style_errors_count] += 1
            when /^Layout/
                @output_hash[:layout_errors_count] += 1
            when /^Naming/
                @output_hash[:naming_errors_count] += 1
            else
                @output_hash[:code_errors_count] += 1
                @output_hash[:code_errors].push({
                    error: offense.message,
                    location: offense.location
                })
            end
        end
    end
end