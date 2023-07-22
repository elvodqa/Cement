module graphics.transform;

import gl3n.math;
import gl3n.linalg;

alias  mat4d = Matrix!(double, 4, 4);

class Transform {
    vec3 position;
    float scale;
    Quaternion!float rotation;
    mat4d viewMatrix;
}

