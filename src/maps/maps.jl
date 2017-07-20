# maps.jl

"""
A map is any transformation of the form `y = f(x)`, where `x` has type `S` and
`y` has type `T`.
"""
abstract type AbstractMap{T,S}
end

domaintype(map::AbstractMap) = domaintype(typeof(map))
domaintype(::Type{AbstractMap{T,S}}) where {T,S} = S
domaintype(::Type{M}) where {M <: AbstractMap} = domaintype(supertype(M))

rangetype(map::AbstractMap) = rangetype(typeof(map))
rangetype(::Type{AbstractMap{T,S}}) where {T,S} = T
rangetype(::Type{M}) where {M <: AbstractMap} = rangetype(supertype(M))

(*)(map::AbstractMap, x) = applymap(map, x)

(\)(map::AbstractMap, y) = inv(map) * y

apply_inverse(m::AbstractMap, y) = applymap(inv(m), y)

isreal(m::AbstractMap) = isreal(domaintype(m)) && isreal(rangetype(m))
isreal(::Type{T}) where {T<:Number} = isreal(T(0))
isreal(::Type{SVector{N,T}}) where {N,T} = isreal(T)
isreal(::Type{NTuple{N,T}}) where {N,T} = isreal(T)

"""
`return_type(map, U)` is a generic function that computes the return type when
the given map is applied to a variable of type `U`.

For any `AbstractMap{T,S}`, we have that `return_type(map, S) = T`. We also return
`T` if `U` can be promoted to `T` using Julia's promotion system.
"""
# - If the map maps S to T and x has type S, then the result is T
return_type(map::AbstractMap{T,S}, ::Type{S}) where {T,S} = T
# - If x has a type different from S, perhaps it can be promoted to S?
return_type(map::AbstractMap{T,S}, ::Type{U}) where {T,S,U} = _return_type(map, T, promotes_to(U,S))
# -- Yes, it can, let's return T.
_return_type(map, ::Type{T}, ::Type{True}) where {T} = T
# -- No, it can not. We return Any.
_return_type(map, ::Type{T}, ::Type{False}) where {T} = Any
