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

require 'json'
require 'fileutils'

module AppStoreMetadata
    ROOT = File.join(__dir__, 'appstoreconnect')
    METADATA_FILE = File.join(ROOT, 'metadata.json')
    SCREENSHOTS_ROOT = File.join(ROOT, 'screenshots')

    ASC_LOCALES = {
        'en' => %w[en-US en-AU en-GB en-CA],
        'de' => %w[de-DE],
        'es' => %w[es-ES es-MX],
        'fr' => %w[fr-FR fr-CA],
        'hi' => %w[hi],
        'ko' => %w[ko]
    }.freeze

    TEXT_FIELDS = %w[
        name subtitle description keywords promotional_text release_notes
        marketing_url privacy_url support_url
    ].freeze

    def self.stage(platform:, output_dir:)
        platform_key = platform.to_s
        metadata = load_metadata

        metadata_dir = File.join(output_dir, 'metadata')
        screenshots_dir = File.join(output_dir, 'screenshots')

        FileUtils.rm_rf(output_dir)
        FileUtils.mkdir_p([metadata_dir, screenshots_dir])

        ASC_LOCALES.each do |short, asc_locales|
            locale_data = metadata[short] || {}
            asc_locales.each do |asc|
                write_metadata(locale_data, File.join(metadata_dir, asc))
                copy_screenshots(short, platform_key, locale_data, File.join(screenshots_dir, asc))
            end
        end

        [metadata_dir, screenshots_dir]
    end

    def self.load_metadata
        raise "Missing metadata file at #{METADATA_FILE}" unless File.exist?(METADATA_FILE)

        JSON.parse(File.read(METADATA_FILE))
    end

    def self.write_metadata(locale_data, dir)
        FileUtils.mkdir_p(dir)
        TEXT_FIELDS.each do |field|
            value = locale_data[field]
            next if value.nil? || value.to_s.strip.empty?

            File.write(File.join(dir, "#{field}.txt"), value)
        end
    end

    def self.copy_screenshots(short_locale, platform_key, locale_data, dir)
        FileUtils.mkdir_p(dir)
        platform_screenshots = locale_data.fetch('screenshots') do
            raise "Missing 'screenshots' for locale '#{short_locale}' in #{METADATA_FILE}"
        end
        devices = platform_screenshots.fetch(platform_key) do
            raise "Missing screenshots for platform '#{platform_key}' in locale '#{short_locale}'"
        end

        devices.each do |device, files|
            files.each_with_index do |name, idx|
                src = File.join(SCREENSHOTS_ROOT, short_locale, device, name)
                raise "Missing screenshot file: #{src}" unless File.exist?(src)

                base = File.basename(name, '.png')
                dst = File.join(dir, format('%<device>s_%<idx>02d_%<name>s.png', device: device, idx: idx, name: base))
                FileUtils.cp(src, dst)
            end
        end
    end
end
