#include<GL/glu.h> 

void main(int argc, char**argv) {
    glutInit(&argc, argv);
    glutInitWindowPosition(100,100);
    glutInitWindowSize(500,500);
    glutCreateWindow("Hello World");
    glutMainLoop();
}
