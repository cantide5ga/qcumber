TYPE PageType
        value AS INTEGER
END TYPE
   
TYPE DataType
        value AS STRING * 1
END TYPE

TYPE DirectionType
        value AS STRING * 1
END TYPE

TYPE JoyType
        value AS INTEGER
END TYPE

TYPE HueType
    value AS INTEGER
END TYPE

' Compile time type safety
TYPE SafeType
        ViewPage AS PageType
        Buffer AS PageType
        SpriteSheet AS PageType
        TileSheet AS PageType
        Integers AS DataType
        Longs AS DataType
        SFloat AS DataType
        DFloat AS DataType
        Rightward AS DirectionType
        Leftward AS DirectionType
        Downward AS DirectionType
        Upward AS DirectionType
        RightButton AS JoyType
        DownButton AS JoyType
        LeftButton AS JoyType
        UpButton AS JoyType
        AButton AS JoyType
        BButton AS JoyType
        StartButton AS JoyType
        SelectButton AS JoyType
        KeyHandlerKillCall AS JoyType
        Black AS HueType
        Gray AS HueType
        Indigo AS HueType
        Blue AS HueType
        Violet AS HueType
        Pink AS HueType
        Red AS HueType
        Orange AS HueType
        Burnt AS HueType
        Brown AS HueType
        Forest AS HueType
        Green AS HueType
        Celadon AS HueType
        Cadet AS HueType
END TYPE


