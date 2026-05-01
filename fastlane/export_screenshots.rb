# frozen_string_literal: true

# Jottre: Minimalistic jotting for iPhone, iPad and Mac.
# Copyright (C) 2021-2026 Anton Lorani
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.

require 'fileutils'

# Export artboards from a Sketch file and group by locale & platform.
#
# Artboards must be named: <platform>_<name>_<locale>
# Example: iphone_jotting_de, iphone_quick_note_de
# Output structure: <output_dir>/<locale>/<platform>/<name>.png
module ExportScreenshots
    LOCALES = %w[de en es fr hi ko].freeze

    # Exports artboards from the given Sketch file into output_dir, grouped by
    # locale and platform.
    def self.export(sketch_file:, output_dir:)
        ui = FastlaneCore::UI
        ui.user_error!("Sketch file not found: #{sketch_file}") unless File.exist?(sketch_file)

        FileUtils.mkdir_p(output_dir)

        ui.message("Exporting artboards from #{sketch_file}...")
        unless system('sketchtool', 'export', 'artboards', sketch_file, "--output=#{output_dir}")
            ui.user_error!('sketchtool export failed (is sketchtool in your PATH?)')
        end

        files = Dir.glob(File.join(output_dir, '*.png'))
        ui.user_error!("No PNG files found in #{output_dir}") if files.empty?

        ui.message("Grouping #{files.length} file(s)...")
        files.each { |file| group_file(file, output_dir: output_dir, ui: ui) }
        ui.message('Done.')
    end

    def self.group_file(file, output_dir:, ui:)
        source_name = File.basename(file)
        platform, *rest = File.basename(file, '.png').split('_')
        locale = rest.pop
        name = rest.join('_')

        if platform.nil? || locale.nil? || name.empty?
            ui.message("  Skipping #{source_name} (doesn't match <platform>_<name>_<locale>)")
            return
        end

        unless LOCALES.include?(locale)
            ui.message("  Skipping #{source_name} (unknown locale: #{locale})")
            return
        end

        destination = File.join(output_dir, locale, platform, "#{name}.png")
        FileUtils.mkdir_p(File.dirname(destination))
        FileUtils.mv(file, destination)
        ui.message("  #{source_name} -> #{destination}")
    end
end
