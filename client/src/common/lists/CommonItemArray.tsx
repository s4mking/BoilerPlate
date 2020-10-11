import {} from "React";

interface Column<ExpectedItem> {
width: number, title: string, contentDisplayer: (param: ExpectedItem) => React.ReactChild;
}

interface CommonItemArrayProps<T> {
    items: T[];
    columns: Column<T>[];
}

const CommonItemArray  = ({items, columns}: CommonItemArrayProps<T>) => {

}

export default CommonItemArray;
