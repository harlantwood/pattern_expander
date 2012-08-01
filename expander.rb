module Expander
  CHARACTER_CLASSES = {
    "\\w" => ('a'..'z').to_a + ('0'..'9').to_a,
    "\\d" => ('0'..'9').to_a,
    "\\l" => ('a'..'z').to_a 
  } 

  def expand(pattern)
    combine_all(*substitute_character_classes(parse(pattern)))
  end

  def expand_strings(pattern)
    expand(pattern).map(&:join)
  end

  def parse(pattern)
    parse_groups(pattern).map do |group|
      group.split("|")
    end
  end

  def substitute_character_classes(groups)
    groups.map do |group|
      group.inject([]) do |memo, item|
        memo += CHARACTER_CLASSES[item] || [item]
      end
    end
  end

  def parse_groups(pattern)
    pattern.scan(/\[(.*?)\]/).flatten
  end

  def combine_all(xs, ys, *tail)
    result = combine(xs,ys)
    if tail == []
      result
    else
      combine_all(result, *tail)
    end
  end

  def combine(xs, ys)
    xs.inject([]) do |m, x|
      ys.each do |y|
        m << [x,y].flatten
      end
      m
    end
  end
end
