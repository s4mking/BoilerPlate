import {Book} from "../../utils/mockThatApi";
import CommonItemArray from "../../common/lists/CommonItemArray";

interface BookListProps {
    books: Book[];
    suppressBook: (book: Book) => void;
    editBook: (book: Book) => void;
}

const BookList = ({books, suppressBook, editBook}:BookListProps) => {
    return <CommonItemArray
        items={books}
        columns={
            [
                {width: 100, title: "titre", contentDisplayer: (book => book.title)},
                {width: 200, title: "auteur", contentDisplayer: (book => book.author)},
                {width: 200, title: "actions", contentDisplayer: (book => <CommonItemActions onSuppress={suppressBook(book)} onEdit={editBook(book)} />)}
            ]
        }/>
}

export default BookList;
