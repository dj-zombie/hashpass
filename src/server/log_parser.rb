##
# Searches for a keyword in a log
# returns the value to the right of search_word
#
def read_log(search_word, selection_index, filename)
  tail = `tail -n 24 logs/#{filename}`
  return 'EMPTY' if tail.empty?
  return if tail.length < 13
  line = tail.split("\n").grep(/#{search_word}/)[0]
  line.to_s.split('.: ')[1]
end
