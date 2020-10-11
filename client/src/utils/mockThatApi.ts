export interface Book {
    author: string;
    title: string;
    id: string;
    pages: Page[];
}

export interface Page {
    numPage: number;
    text: string;
}

let bookList: Book[] = [{author: "Victor Hugo", title: "les misaires de valjhean", id: "1", pages: [{numPage: 1, text: "Jean valjean, ce vaurien"}, {numPage: 2, text: "Jean valjean, ce héros"}, {numPage: 1234, text: "Waterloo, ce désastre"}]}]

export const readBookList = (): Book[] => {
    return bookList;
}

export const createBook = (book: Book): Book[] => {
    bookList.push(book);
    return bookList;
}

export const updateBook = (book: Book): Book[] => {
    bookList.forEach((singleBook, index) => {
        if (singleBook.id === book.id){
            bookList[index] = book;
        }
    });
    return bookList;
}

export const deleteBook = (bookToDelete: Book): Book[] => {
    bookList = bookList.filter((singleBook, index) => {
        return !(singleBook.id === bookToDelete.id);
    });
    return bookList;
}
