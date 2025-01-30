String capitalize(String input) {
  return input
      .replaceAll('_', ' ') // Replace underscores with spaces
      .split(' ') // Split into words
      .map((word) =>
  word[0].toUpperCase() + word.substring(1)) // Capitalize each word
      .join(' '); // Join words back together
}