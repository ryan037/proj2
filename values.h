#ifndef VALUES_H
#define VALUES_H

#include<iostream>

enum ValueType
{
    type_class = 1,
    type_function = 2,
    type_integer = 3,
    type_real = 4,
    type_bool = 5,
    type_string = 6,
    type_void = 7,
    type_array = 8
};
inline std::string EnumToString(const ValueType value)
{
    switch (value)
    {
    case ValueType::type_class:
        return "class";
    case ValueType::type_function:
        return "function";
    case ValueType::type_integer:
        return "int";
    case ValueType::type_real:
        return "double";
    case ValueType::type_string:
        return "string";
    case ValueType::type_void:
        return "void";
    default:
        return std::to_string(value);
    }
}
#endif
