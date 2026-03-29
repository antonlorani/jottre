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

module Versioning
    # Returns the latest semver tag or nil if none exists.
    def self.latest_tag
        tag = `git describe --tags $(git rev-list --tags --max-count=1) 2>/dev/null || true`.strip
        tag.empty? ? nil : tag
    end

    # Returns true if HEAD is already tagged.
    def self.head_tagged?(tag)
        `git describe --exact-match --tags HEAD 2>/dev/null || true`.strip == tag
    end

    # Returns the next version bump strategy suitable since the last tag, or
    # nil if no version marker is present.
    def self.bump_strategy(since_tag:)
        range = since_tag ? "#{since_tag}..HEAD" : 'HEAD'
        subjects = `git log #{range} --pretty=format:'%s'`.strip

        strategy = nil
        subjects.each_line do |line|
            line = line.strip
            next if line.empty?

            if line.match?(/^major:/i)
                strategy = 'major'
                break
            elsif line.match?(/^minor:/i) && strategy != 'major'
                strategy = 'minor'
            elsif line.match?(/^patch:/i) && strategy.nil?
                strategy = 'patch'
            end
        end
        strategy
    end

    # Performs a semver bump on a given semantic version.
    def self.bump_version(current:, bump_strategy:)
        parts = current.split('.').map(&:to_i)
        parts << 0 while parts.length < 3
        major, minor, patch = parts

        case bump_strategy
        when 'major' then "#{major + 1}.0.0"
        when 'minor' then "#{major}.#{minor + 1}.0"
        else              "#{major}.#{minor}.#{patch + 1}"
        end
    end
end
