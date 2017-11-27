#!/bin/python

def print_everything(*args):
    for count, thing in enumerate(args):
        print( '{0}. {1}'.format(count, thing))
                
print_everything('apple', 'banana', 'cabbage')
print_everything('apple', 'banana', 'cabbage',)


def table_things(**kwargs):
    for name, value in kwargs.items():
        print( '{0} = {1}'.format(name, value))
        
table_things(apple = 'fruit', cabbage = 'vegetable')
table_things(apple = 'fruit', cabbage = 'vegetable',)

