module graphics.view;

import gl3n.linalg;

class View {
    int x;
    int y;
    int width;
    int height;

    mat4 projection;
    mat4 view;

    this(int x, int y, int width, int height) {
        this.x = x;
        this.y = y;
        this.width = width;
        this.height = height;
        // static Matrix orthographic(mt left, mt right, mt bottom, mt top, mt near, mt far);
        projection = mat4.orthographic(0, width, height, 0, -1, 1);
        view = mat4.translation(x, y, 0); // move to x and y ?
    }

    void resize(int width, int height) {
        projection = mat4.orthographic(0, width, height, 0, -1, 1);
    }
}   