package vector

import "core:math"
import rl "vendor:raylib"

// VECTOR2

Vector2Length :: proc(v: rl.Vector2) -> f32 {
	return math.sqrt_f32((v.x * v.x) + (v.y * v.y))
}

// Calculate vector square length
Vector2LengthSqr :: proc(v: rl.Vector2) -> f32 {
	return (v.x * v.x) + (v.y * v.y)
}

// Calculate two vectors dot product
Vector2DotProduct :: proc(v1: rl.Vector2, v2: rl.Vector2) -> f32 {
	result := (v1.x * v2.x + v1.y * v2.y)

	return result
}

// Calculate distance between two vectors
Vector2Distance :: proc(v1: rl.Vector2, v2: rl.Vector2) -> f32 {
	result := math.sqrt_f32((v1.x - v2.x) * (v1.x - v2.x) + (v1.y - v2.y) * (v1.y - v2.y))

	return result
}

// Calculate square distance between two vectors
Vector2DistanceSqr :: proc(v1: rl.Vector2, v2: rl.Vector2) -> f32 {
	result := ((v1.x - v2.x) * (v1.x - v2.x) + (v1.y - v2.y) * (v1.y - v2.y))

	return result
}

// Calculate angle between two vectors
// NOTE: Angle is calculated from origin point (0, 0)
Vector2Angle :: proc(v1: rl.Vector2, v2: rl.Vector2) -> f32 {

	dot := v1.x * v2.x + v1.y * v2.y
	det := v1.x * v2.y - v1.y * v2.x

	return math.atan2_f32(det, dot)
}

// Calculate angle defined by a two vectors line
// NOTE: Parameters need to be normalized
// Current implementation should be aligned with glm::angle
Vector2LineAngle :: proc(start: rl.Vector2, end: rl.Vector2) -> f32 {

	// TODO(10/9/2023): Currently angles move clockwise, determine if this is wanted behavior
	result := -math.atan2_f32(end.y - start.y, end.x - start.x)

	return result
}

// Scale vector (multiply by value)
Vector2Scale :: proc(v: rl.Vector2, scale: f32) -> rl.Vector2 {
	return {v.x * scale, v.y * scale}
}

// Multiply vector by vector
Vector2Multiply :: proc(v1: rl.Vector2, v2: rl.Vector2) -> rl.Vector2 {
	return {v1.x * v2.x, v1.y * v2.y}
}

// Negate vector
Vector2Negate :: proc(v: rl.Vector2) -> rl.Vector2 {
	return {-v.x, -v.y}
}

// Divide vector by vector
Vector2Divide :: proc(v1: rl.Vector2, v2: rl.Vector2) -> rl.Vector2 {
	return {v1.x / v2.x, v1.y / v2.y}
}

// Normalize provided vector
Vector2Normalize :: proc(v: rl.Vector2) -> rl.Vector2 {
	result := rl.Vector2{0, 0}
	length := Vector2Length(v)

	if (length > 0) {
		ilength := 1.0 / length
		result.x = v.x * ilength
		result.y = v.y * ilength
	}

	return result
}

// Transforms a Vector2 by a given Matrix
Vector2Transform :: proc(v: rl.Vector2, mat: rl.Matrix) -> rl.Vector2 {
	result := rl.Vector2{0, 0}

	x := v.x
	y := v.y
	z: f32 = 0.0

	m := matrix_flatten(mat)
	result.x = m[0] * x + m[4] * y + m[8] * z + m[12]
	result.y = m[1] * x + m[5] * y + m[9] * z + m[13]

	return result
}

// Calculate linear interpolation between two vectors
Vector2Lerp :: proc(v1: rl.Vector2, v2: rl.Vector2, amount: f32) -> rl.Vector2 {
	return v1 + (v2 - v1) * amount
}

// Calculate reflected vector to normal
Vector2Reflect :: proc(v: rl.Vector2, normal: rl.Vector2) -> rl.Vector2 {
	dotProduct := Vector2DotProduct(v, normal)
	return v - (2 * normal) * dotProduct
}

// Rotate vector by angle
Vector2Rotate :: proc(v: rl.Vector2, angle: f32) -> rl.Vector2 {
	cosres := math.cos_f32(angle)
	sinres := math.sin_f32(angle)
	return rl.Vector2{v.x * cosres - v.y * sinres, v.x * sinres + v.y * cosres}
}

// Move Vector towards target
Vector2MoveTowards :: proc(v: rl.Vector2, target: rl.Vector2, maxDistance: f32) -> rl.Vector2 {
	d := target - v
	value := Vector2LengthSqr(d)

	if ((value == 0) || ((maxDistance >= 0) && (value <= maxDistance * maxDistance))) {
		return target
	}

	dist := math.sqrt_f32(value)

	return v + d / dist * maxDistance
}

// Invert the given vector
Vector2Invert :: proc(v: rl.Vector2) -> rl.Vector2 {
	return 1.0 / v
}

// Clamp the components of the vector between
// min and max values specified by the given vectors
Vector2Clamp :: proc(v: rl.Vector2, min: rl.Vector2, max: rl.Vector2) -> rl.Vector2 {
	return rl.Vector2{clamp(v.x, min.x, max.x), clamp(v.y, min.x, max.y)}
}

// Clamp the magnitude of the vector between two min and max values
Vector2ClampValue :: proc(v: rl.Vector2, min: f32, max: f32) -> rl.Vector2 {
	length := Vector2LengthSqr(v)
	if (length > 0.0) {
		length = math.sqrt_f32(length)

		if (length < min) {
			scale := min / length
			return v * scale
		} else if (length > max) {
			scale := max / length
			return v * scale
		}
	}

	return v
}

// Check whether two given vectors are almost equal
Vector2Equals :: proc(p: rl.Vector2, q: rl.Vector2) -> bool {
	EPSILON :: 0.000001

	return(
		((abs(p.x - q.x)) <= (EPSILON * max(1.0, max(abs(p.x), abs(q.x))))) &&
		((abs(p.y - q.y)) <= (EPSILON * max(1.0, max(abs(p.y), abs(q.y))))) \
	)

}


// #Vector3

// Vector with components value 0.0f
Vector3Zero :: proc() -> rl.Vector3
{
    return { 0.0, 0.0, 0.0 };
}

// Vector with components value 1.0f
Vector3One :: proc() -> rl.Vector3
{
    return { 1.0, 1.0, 1.0 };
}

// Calculate two vectors cross product
Vector3CrossProduct :: proc(v1: rl.Vector3, v2: rl.Vector3) -> rl.Vector3
{
	return v1.yzx * v2.zxy - v1.zxy * v2.yzx
}

// Calculate one vector perpendicular vector
Vector3Perpendicular :: proc(v: rl.Vector3) -> rl.Vector3
{
    m := abs(v.x);
    cardinalAxis := rl.Vector3{1.0, 0.0, 0.0};

    if abs(v.y) < m
    {
        m = abs(v.y);
        cardinalAxis = {0.0, 1.0, 0.0};
    }

    if abs(v.z) < m
    {
        cardinalAxis = {0.0, 0.0, 1.0};
    }

    // Cross product between vectors
    result := rl.Vector3{
			v.y*cardinalAxis.z - v.z*cardinalAxis.y,
			v.z*cardinalAxis.x - v.x*cardinalAxis.z,
			v.x*cardinalAxis.y - v.y*cardinalAxis.x,
	}

    return result;
}

// Calculate vector length
Vector3Length :: proc(v: rl.Vector3) -> f32
{
    return math.sqrt_f32(v.x*v.x + v.y*v.y + v.z*v.z);
}

// Calculate vector square length
Vector3LengthSqr :: proc(v: rl.Vector3) -> f32
{
    return v.x*v.x + v.y*v.y + v.z*v.z;
}

// Calculate two vectors dot product
Vector3DotProduct :: proc(v1: rl.Vector3, v2: rl.Vector3) -> f32
{
    return (v1.x*v2.x + v1.y*v2.y + v1.z*v2.z);
}

// Calculate distance between two vectors
Vector3Distance :: proc(v1: rl.Vector3, v2: rl.Vector3) -> f32
{

    dx := v2.x - v1.x;
    dy := v2.y - v1.y;
    dz := v2.z - v1.z;
    return math.sqrt_f32(dx*dx + dy*dy + dz*dz);

}

// Calculate square distance between two vectors
Vector3DistanceSqr :: proc(v1: rl.Vector3, v2: rl.Vector3) -> f32
{
    dx := v2.x - v1.x;
    dy := v2.y - v1.y;
    dz := v2.z - v1.z;
    return dx*dx + dy*dy + dz*dz;
}

// Calculate angle between two vectors
Vector3Angle :: proc(v1: rl.Vector3, v2: rl.Vector3) -> f32
{
    cross := Vector3CrossProduct(v1, v2)
    len := Vector3Length(cross)
    dot := Vector3DotProduct(v1, v2)
    return math.atan2_f32(len, dot);
}

// Negate provided vector (invert direction)
Vector3Negate :: proc(v: rl.Vector3) -> rl.Vector3
{
		return -v
}

// Divide vector by vector
Vector3Divide :: proc(v1: rl.Vector3, v2: rl.Vector3) -> rl.Vector3
{
		return v1 / v2
}

// Normalize provided vector
Vector3Normalize :: proc(v: rl.Vector3) -> rl.Vector3
{
    length := Vector3Length(v);
    if length == 0.0 {
		return Vector3Zero()
	}
    ilength := 1.0/length;

	return v * ilength
}

Vector3Norm:: proc(v: rl.Vector3) -> f32 {
	return math.sqrt_f32(Vector3DotProduct(v,v))
}

//Calculate the projection of the vector v1 on to v2
Vector3Project :: proc(v1: rl.Vector3, v2: rl.Vector3) -> rl.Vector3
{
    v1dv2 := Vector3DotProduct(v1,v2);
    v2dv2 := Vector3DotProduct(v2,v2);

    mag := v1dv2/v2dv2;
	return v2 * mag
}

//Calculate the projection of the vector v to the plane defined by normal n
Vector3ProjectToPlane :: proc(v: rl.Vector3, n: rl.Vector3) -> rl.Vector3 {
	d := Vector3DotProduct(v, n) / Vector3Norm(n)
	p := d * Vector3Normalize(n)
	return v - p
}

//Calculate the rejection of the vector v1 on to v2
Vector3Reject :: proc(v1: rl.Vector3, v2: rl.Vector3) -> rl.Vector3
{
    v1dv2 := Vector3DotProduct(v1,v2);
    v2dv2 := Vector3DotProduct(v2,v2);

    mag := v1dv2/v2dv2;

	return v1 - (v2*mag)
}

// Orthonormalize provided vectors
// Makes vectors normalized and orthogonal to each other
// Gram-Schmidt function implementation
Vector3OrthoNormalize :: proc(v1: ^rl.Vector3, v2: ^rl.Vector3)
{
    length : f32 = 0.0;
    ilength : f32 = 0.0;

    // Vector3Normalize(*v1);
	v := Vector3Normalize(v1^);
    // Vector3CrossProduct(*v1, *v2)
    vn1 := Vector3CrossProduct(v1^, v2^);

    // Vector3Normalize(vn1);
    v = Vector3Normalize(vn1)

    // Vector3CrossProduct(vn1, *v1)
    vn2 := Vector3CrossProduct(vn1, v1^);

    v2^ = vn2;
}

// Transforms a Vector3 by a given Matrix
Vector3Transform :: proc(v: rl.Vector3, mat: rl.Matrix) -> rl.Vector3
{

    x := v.x;
    y := v.y;
    z := v.z;
	m := matrix_flatten(mat)

    return {
		m[0]*x + m[4]*y + m[8]*z + m[12],
    	m[1]*x + m[5]*y + m[9]*z + m[13],
	    m[2]*x + m[6]*y + m[10]*z + m[14],	
	}

}

// Transform a vector by quaternion rotation
Vector3RotateByQuaternion :: proc(v: rl.Vector3, q: rl.Quaternion) -> rl.Vector3
{
	return {
    	v.x*(q.x*q.x + q.w*q.w - q.y*q.y - q.z*q.z) + v.y*(2*q.x*q.y - 2*q.w*q.z) + v.z*(2*q.x*q.z + 2*q.w*q.y),
    	v.x*(2*q.w*q.z + 2*q.x*q.y) + v.y*(q.w*q.w - q.x*q.x + q.y*q.y - q.z*q.z) + v.z*(-2*q.w*q.x + 2*q.y*q.z),
    	v.x*(-2*q.w*q.y + 2*q.x*q.z) + v.y*(2*q.w*q.x + 2*q.y*q.z)+ v.z*(q.w*q.w - q.x*q.x - q.y*q.y + q.z*q.z),
	}

}

// Rotates a vector around an axis
Vector3RotateByAxisAngle :: proc(v: rl.Vector3, axis: rl.Vector3, angle: f32) -> rl.Vector3
{
    // Using Euler-Rodrigues Formula
    // Ref.: https://en.wikipedia.org/w/index.php?title=Euler%E2%80%93Rodrigues_formula

    // Vector3Normalize(axis);
	axis := Vector3Normalize(axis)

    ang := angle / 2.0;
    a := math.sin_f32(ang);
    b := axis.x*a;
    c := axis.y*a;
    d := axis.z*a;
    a = math.cos_f32(ang);
    w := rl.Vector3{ b, c, d };

    // Vector3CrossProduct()ct(w, v)
	wv := Vector3CrossProduct(w, v)
    // Vector3 wv = { w.y*v.z - w.z*v.y, w.z*v.x - w.x*v.z, w.x*v.y - w.y*v.x };

    // Vector3CrossProduct(w, wv)
	wwv := Vector3CrossProduct(w, wv)
    // Vector3 wwv = { w.y*wv.z - w.z*wv.y, w.z*wv.x - w.x*wv.z, w.x*wv.y - w.y*wv.x };

    // Vector3Scale(wv, 2*a)
    a *= 2
	wv *= a
    // wv.x *= a;
    // wv.y *= a;
    // wv.z *= a;

    // Vector3Scale(wwv, 2)
	wwv *= 2

	return v + wv + wwv

    // result.x += wv.x;
    // result.y += wv.y;
    // result.z += wv.z;

    // result.x += wwv.x;
    // result.y += wwv.y;
    // result.z += wwv.z;

    // return result;
}

// Calculate linear interpolation between two vectors
Vector3Lerp :: proc(v1: rl.Vector3, v2: rl.Vector3, amount: f32) -> rl.Vector3
{
	return v1 + (v2 - v1) * amount
}

// Calculate reflected vector to normal
Vector3Reflect :: proc(v:rl.Vector3, normal:rl.Vector3) -> rl.Vector3
{

    // I is the original vector
    // N is the normal of the incident plane
    // R = I - (2*N*(DotProduct[I, N]))

    dotProduct := Vector3DotProduct(v, normal);

	return v - 2.0 * normal * dotProduct
}

// Get min value for each pair of components
Vector3Min :: proc(v1: rl.Vector3, v2: rl.Vector3) -> rl.Vector3
{
	return rl.Vector3{
	    min(v1.x, v2.x),
	    min(v1.y, v2.y),
	    min(v1.z, v2.z),
	}
}

// Get max value for each pair of components
Vector3Max :: proc(v1:rl.Vector3, v2:rl.Vector3) -> rl.Vector3
{
	return rl.Vector3{
	    min(v1.x, v2.x),
	    min(v1.y, v2.y),
	    min(v1.z, v2.z),
	}
}

// Compute barycenter coordinates (u, v, w) for point p with respect to triangle (a, b, c)
// NOTE: Assumes P is on the plane of the triangle
Vector3Barycenter :: proc(p: rl.Vector3, a: rl.Vector3, b: rl.Vector3, c: rl.Vector3) -> rl.Vector3
{

    // Vector3 v0 = { b.x - a.x, b.y - a.y, b.z - a.z };   // Vector3Subtract(b, a)
    // Vector3 v1 = { c.x - a.x, c.y - a.y, c.z - a.z };   // Vector3Subtract(c, a)
    // Vector3 v2 = { p.x - a.x, p.y - a.y, p.z - a.z };   // Vector3Subtract(p, a)
	v0 := b - a
	v1 := c - a
	v2 := p - a
		
	d00 := Vector3DotProduct(v0, v0)
	d01 := Vector3DotProduct(v0, v1)
	d11 := Vector3DotProduct(v1, v1)
	d20 := Vector3DotProduct(v2, v0)
	d21 := Vector3DotProduct(v2, v1)

	denom := d00*d11 - d01*d01;

	return {
	    (d11*d20 - d01*d21)/denom,
	    (d00*d21 - d01*d20)/denom,
	    1.0 - (p.z + p.y),
	}
}

// Projects a Vector3 from screen space into object space
// NOTE: We are avoiding calling other raymath functions despite available
// Vector3Unproject :: proc(source: rl.Vector3, projection: rl.Matrix, view: rl.Matrix) -> rl.Vector3
// {
// 	p := matrix_flatten(projection)
// 	v := matrix_flatten(view)
//     // Calculate unprojected matrix (multiply view matrix by projection matrix) and invert it
//     matViewProj = rl.Matrix{      // MatrixMultiply(view, projection);
//         v[0]*p[0] + v[1]*p[4] + v[2]*p[8] + v[3]*p[12],
//         v[0]*p[1] + v[1]*p[5] + v[2]*p[9] + v[3]*p[13],
//         v[0]*p[2] + v[1]*p[6] + v[2]*p[10] + v[3]*p[14],
//         v[0]*p[3] + v[1]*p[7] + v[2]*p[11] + v[3]*p[15],
//         v[4]*p[0] + v[5]*p[4] + v[6]*p[8] + v[7]*p[12],
//         v[4]*p[1] + v[5]*p[5] + v[6]*p[9] + v[7]*p[13],
//         v[4]*p[2] + v[5]*p[6] + v[6]*p[10] + v[7]*p[14],
//         v[4]*p[3] + v[5]*p[7] + v[6]*p[11] + v[7]*p[15],
//         v[8]*p[0] + v[9]*p[4] + v[10]*p[8] + v[11]*p[12],
//         v[8]*p[1] + v[9]*p[5] + v[10]*p[9] + v[11]*p[13],
//         v[8]*p[2] + v[9]*p[6] + v[10]*p[10] + v[11]*p[14],
//         v[8]*p[3] + v[9]*p[7] + v[10]*p[11] + v[11]*p[15],
//         v[12]*p[0] + v[13]*p[4] + v[14]*p[8] + v[15]*p[12],
//         v[12]*p[1] + v[13]*p[5] + v[14]*p[9] + v[15]*p[13],
//         v[12]*p[2] + v[13]*p[6] + v[14]*p[10] + v[15]*p[14],
//         v[12]*p[3] + v[13]*p[7] + v[14]*p[11] + v[15]*p[15] };

//     // Calculate inverted matrix -> MatrixInvert(matViewProj);
//     // Cache the matrix values (speed optimization)
//     float a00 = matViewProj.m0, a01 = matViewProj.m1, a02 = matViewProj.m2, a03 = matViewProj.m3;
//     float a10 = matViewProj.m4, a11 = matViewProj.m5, a12 = matViewProj.m6, a13 = matViewProj.m7;
//     float a20 = matViewProj.m8, a21 = matViewProj.m9, a22 = matViewProj.m10, a23 = matViewProj.m11;
//     float a30 = matViewProj.m12, a31 = matViewProj.m13, a32 = matViewProj.m14, a33 = matViewProj.m15;

//     float b00 = a00*a11 - a01*a10;
//     float b01 = a00*a12 - a02*a10;
//     float b02 = a00*a13 - a03*a10;
//     float b03 = a01*a12 - a02*a11;
//     float b04 = a01*a13 - a03*a11;
//     float b05 = a02*a13 - a03*a12;
//     float b06 = a20*a31 - a21*a30;
//     float b07 = a20*a32 - a22*a30;
//     float b08 = a20*a33 - a23*a30;
//     float b09 = a21*a32 - a22*a31;
//     float b10 = a21*a33 - a23*a31;
//     float b11 = a22*a33 - a23*a32;

//     // Calculate the invert determinant (inlined to avoid double-caching)
//     float invDet = 1.0/(b00*b11 - b01*b10 + b02*b09 + b03*b08 - b04*b07 + b05*b06);

//     Matrix matViewProjInv = {
//         (a11*b11 - a12*b10 + a13*b09)*invDet,
//         (-a01*b11 + a02*b10 - a03*b09)*invDet,
//         (a31*b05 - a32*b04 + a33*b03)*invDet,
//         (-a21*b05 + a22*b04 - a23*b03)*invDet,
//         (-a10*b11 + a12*b08 - a13*b07)*invDet,
//         (a00*b11 - a02*b08 + a03*b07)*invDet,
//         (-a30*b05 + a32*b02 - a33*b01)*invDet,
//         (a20*b05 - a22*b02 + a23*b01)*invDet,
//         (a10*b10 - a11*b08 + a13*b06)*invDet,
//         (-a00*b10 + a01*b08 - a03*b06)*invDet,
//         (a30*b04 - a31*b02 + a33*b00)*invDet,
//         (-a20*b04 + a21*b02 - a23*b00)*invDet,
//         (-a10*b09 + a11*b07 - a12*b06)*invDet,
//         (a00*b09 - a01*b07 + a02*b06)*invDet,
//         (-a30*b03 + a31*b01 - a32*b00)*invDet,
//         (a20*b03 - a21*b01 + a22*b00)*invDet };

//     // Create quaternion from source point
//     Quaternion quat = { source.x, source.y, source.z, 1.0 };

//     // Multiply quat point by unprojecte matrix
//     Quaternion qtransformed = {     // QuaternionTransform(quat, matViewProjInv)
//         matViewProjInv.m0*quat.x + matViewProjInv.m4*quat.y + matViewProjInv.m8*quat.z + matViewProjInv.m12*quat.w,
//         matViewProjInv.m1*quat.x + matViewProjInv.m5*quat.y + matViewProjInv.m9*quat.z + matViewProjInv.m13*quat.w,
//         matViewProjInv.m2*quat.x + matViewProjInv.m6*quat.y + matViewProjInv.m10*quat.z + matViewProjInv.m14*quat.w,
//         matViewProjInv.m3*quat.x + matViewProjInv.m7*quat.y + matViewProjInv.m11*quat.z + matViewProjInv.m15*quat.w };

//     // Normalized world points in vectors
//     result.x = qtransformed.x/qtransformed.w;
//     result.y = qtransformed.y/qtransformed.w;
//     result.z = qtransformed.z/qtransformed.w;

//     return result;
// }

// Invert the given vector
Vector3Invert :: proc(v: rl.Vector3) -> rl.Vector3
{
		return 1.0/v
}

// Clamp the components of the vector between
// min and max values specified by the given vectors
Vector3Clamp :: proc(v: rl.Vector3, mn: rl.Vector3, mx: rl.Vector3) -> rl.Vector3
{
	return {
	    min(mx.x, max(mn.x, v.x)),
	    min(mx.y, max(mn.y, v.y)),
	    min(mx.z, max(mn.z, v.z)),
	}
}

// Clamp the magnitude of the vector between two values
Vector3ClampValue :: proc(v: rl.Vector3, min: f32, max: f32) -> rl.Vector3
{
    length := Vector3LengthSqr(v)
    if (length > 0.0)
    {
        length = math.sqrt_f32(length);

        if (length < min)
        {
            scale := min/length
			return v * scale
        }
        else if (length > max)
        {
            scale := max/length;
			return v * scale
        }
    }

    return v;
}

// Check whether two given vectors are almost equal
Vector3Equals :: proc(p: rl.Vector3, q: rl.Vector3) -> bool
{
    EPSILON :: 0.000001

    return((abs(p.x - q.x)) <= (EPSILON*max(1.0, max(abs(p.x), abs(q.x))))) &&
                 ((abs(p.y - q.y)) <= (EPSILON*max(1.0, max(abs(p.y), abs(q.y))))) &&
                 ((abs(p.z - q.z)) <= (EPSILON*max(1.0, max(abs(p.z), abs(q.z)))));

}

// Compute the direction of a refracted ray
// v: normalized direction of the incoming ray
// n: normalized normal vector of the interface of two optical media
// r: ratio of the refractive index of the medium from where the ray comes
//    to the refractive index of the medium on the other side of the surface
Vector3Refract :: proc(v: rl.Vector3, n: rl.Vector3, r: f32) -> rl.Vector3
{
	dot := Vector3DotProduct(v, n)
	d := 1.0 - r*r*(1.0 - dot*dot);

    if (d >= 0.0)
    {
        d = math.sqrt_f32(d);
		return r*v - (r*dot + d)*n
    }

    return Vector3Zero()
}
