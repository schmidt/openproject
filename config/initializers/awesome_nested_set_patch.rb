module AwesomeNestedSetPatch
  def self.included(base)
    base.extend(SingletonMethods)
  end

  module SingletonMethods
    def acts_as_nested_set(options = {})
      return_val = super

      extend ClassMethods

      named_scope :invalid_left_and_rights,
                  :joins => "LEFT OUTER JOIN #{quoted_table_name} AS parent ON " +
                    "#{quoted_table_name}.#{quoted_parent_column_name} = parent.#{primary_key}",
                  :conditions =>
                    "#{quoted_table_name}.#{quoted_left_column_name} IS NULL OR " +
                    "#{quoted_table_name}.#{quoted_right_column_name} IS NULL OR " +
                    "#{quoted_table_name}.#{quoted_left_column_name} >= " +
                      "#{quoted_table_name}.#{quoted_right_column_name} OR " +
                    "(#{quoted_table_name}.#{quoted_parent_column_name} IS NOT NULL AND " +
                      "(#{quoted_table_name}.#{quoted_left_column_name} <= parent.#{quoted_left_column_name} OR " +
                      "#{quoted_table_name}.#{quoted_right_column_name} >= parent.#{quoted_right_column_name}))"

      named_scope :invalid_duplicates_in_columns, lambda {
        scope_string = Array(acts_as_nested_set_options[:scope]).map do |c|
          "#{quoted_table_name}.#{connection.quote_column_name(c)} = duplicates.#{connection.quote_column_name(c)}"
        end.join(" AND ")

        scope_string = scope_string.size > 0 ? scope_string + " AND " : ""

        { :joins => "LEFT OUTER JOIN #{quoted_table_name} AS duplicates ON " +
            scope_string +
            "#{quoted_table_name}.#{primary_key} != duplicates.#{primary_key} AND " +
            "(#{quoted_table_name}.#{quoted_left_column_name} = duplicates.#{quoted_left_column_name} OR " +
            "#{quoted_table_name}.#{quoted_right_column_name} = duplicates.#{quoted_right_column_name})",
          :conditions => "duplicates.#{primary_key} IS NOT NULL" }
      }

      named_scope :invalid_roots, lambda {
        scope_string = Array(acts_as_nested_set_options[:scope]).map do |c|
          "#{quoted_table_name}.#{connection.quote_column_name(c)} = other.#{connection.quote_column_name(c)}"
        end.join(" AND ")

        scope_string = scope_string.size > 0 ? scope_string + " AND " : ""

        { :joins => "LEFT OUTER JOIN #{quoted_table_name} AS other ON " +
            "#{quoted_table_name}.#{primary_key} != other.#{primary_key} AND " +
            "#{quoted_table_name}.#{parent_column_name} IS NULL AND " +
            "other.#{parent_column_name} IS NULL AND " +
            scope_string +
            "#{quoted_table_name}.#{quoted_left_column_name} <= other.#{quoted_right_column_name} AND " +
            "#{quoted_table_name}.#{quoted_right_column_name} >= other.#{quoted_left_column_name}",
          :conditions => "other.#{primary_key} IS NOT NULL",
          :order => quoted_left_column_name }
      }

      return_val
    end

  end

  module ClassMethods
    def selectively_rebuild_silently!
      all_invalid

      invalid_roots, invalid_descendants = all_invalid.partition{ |node| node.send(parent_column_name).nil? }

      while invalid_descendants.size > 0 do
        invalid_descendants_parents = invalid_descendants.map{ |node| find(node.send(parent_column_name)) }

        new_invalid_roots, invalid_descendants = invalid_descendants_parents.partition{ |node| node.send(parent_column_name).nil? }

        invalid_roots += new_invalid_roots

        invalid_descendants.uniq!
      end

      rebuild_silently!(invalid_roots.uniq)
    end

    # Rebuilds the left & rights if unset or invalid.  Also very useful for converting from acts_as_tree.
    # Very similar to original nested_set implementation but uses update_all so that callbacks are not triggered
    def rebuild_silently!(roots = nil)
      # Don't rebuild a valid tree.
      return true if valid?

      scope = lambda{ |node| }
      if acts_as_nested_set_options[:scope]
        scope = lambda{ |node|
          scope_column_names.inject(""){|str, column_name|
            str << "AND #{connection.quote_column_name(column_name)} = #{connection.quote(node.send(column_name.to_sym))} "
          }
        }
      end

      # setup index

      indices = Hash.new do |h, k|
        h[k] = 0
      end

      set_left_and_rights = lambda do |node|

        # set left
        node[left_column_name] = indices[scope.call(node)] += 1
        # find
        children = all(:conditions => ["#{quoted_parent_column_name} = ? #{scope.call(node)}", node],
                       :order => "#{quoted_left_column_name},
                                  #{quoted_right_column_name},
                                  #{acts_as_nested_set_options[:order]}")

        children.each{ |n| set_left_and_rights.call(n) }

        # set right
        node[right_column_name] = indices[scope.call(node)] += 1

        changes = node.changes.inject({}) do |hash, (attribute, values)|
          hash[attribute] = node.send(attribute.to_s)
          hash
        end

        Issue.update_all(changes, { :id => node.id }) unless changes.empty?
      end

      # Find root node(s)
      # or take provided
      root_nodes = if roots.is_a? Array
                     roots
                   elsif roots.present?
                     [roots]
                   else
                     all(:conditions => "#{quoted_parent_column_name} IS NULL",
                         :order => "#{quoted_left_column_name},
                                    #{quoted_right_column_name},
                                    #{acts_as_nested_set_options[:order]}")
                   end

      root_nodes.each do |root_node|
        set_left_and_rights.call(root_node)
      end
    end

    def all_invalid
      invalid = invalid_roots + invalid_left_and_rights + invalid_duplicates_in_columns
      invalid.uniq
    end
  end
end

ActiveRecord::Base.class_eval do
  include AwesomeNestedSetPatch
end
