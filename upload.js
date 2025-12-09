const admin = require("firebase-admin");
const fs = require("fs");
const parse = require("csv-parse/sync").parse;

const serviceAccount = require("./serviceAccountKey.json");

// Init Firebase
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

const db = admin.firestore();

// Read CSV
const csvData = fs.readFileSync("./books.csv", "utf8");

// Parse CSV safely
const records = parse(csvData, {
  columns: true,       // First row = headers
  skip_empty_lines: true,
  relax_quotes: true,
  relax_column_count: true
});

function getCategoryName(id) {
  if (id.startsWith("1")) return "Computer Science";
  if (id.startsWith("2")) return "Natural Science";
  if (id.startsWith("3")) return "Social Science";
  if (id.startsWith("4")) return "Math";
  if (id.startsWith("5")) return "English Language";
  if (id.startsWith("6")) return "Art & Design";
  if (id.startsWith("7")) return "Business";
  return "General";
}

async function uploadBooks() {
  console.log("🚀 Uploading books...");

  const batch = db.batch();
  let count = 0;

  for (const row of records) {

    const docRef = db.collection("books").doc(row.BookID);

    const bookData = {
      bookId: row.BookID,
      title: row.BookTitle,
      categoryId: row.CategoryID,
      author: row.Author,
      authors: [
        row.Author,
        row.Author2,
        row.Author3,
        row.Author4,
        row.Author5
      ].filter(a => a && a.trim() !== ""),
      bookCopies: parseInt(row.BookCopies) || 0,
      publishYear: row.BookPublish,
      publisher: row.PublisherName,
      isbn: row.ISBN,
      status: row.Status,
      imageUrl: row.Book_Image,
      dateAdded: row.BookDateAdded,
      language: row.Language,
      shelfPosition: row.Bookposition,
      description: row.Bookinformation,
      isAvailable: row.Status === "Available",
      category: getCategoryName(row.CategoryID),
      createdAt: admin.firestore.FieldValue.serverTimestamp()
    };

    batch.set(docRef, bookData);
    count++;
    console.log(`✔ Prepared: ${row.BookTitle}`);
  }

  await batch.commit();
  console.log(`\n✅ Successfully uploaded ${count} books!`);
}

uploadBooks().catch(console.error);
