## Abstract type

"""
    AbstractColoringResult{
        partition,
        symmetric,
        decompression,
        M<:AbstractMatrix
    }

Abstract type for the detailed result of a coloring algorithm.

# Type parameters

- `partition::Symbol`: either `:column`, `:row` or `:bidirectional`
- `symmetric::Bool`: either `true` or `false`
- `decompression::Symbol`: either `:direct` or `:substitution`
- `M`: type of the matrix that was colored

# Applicable methods

- [`column_colors`](@ref) and [`column_groups`](@ref) (for a `:column` or `:bidirectional` partition) 
- [`row_colors`](@ref) and [`row_groups`](@ref) (for a `:row` or `:bidirectional` partition)
- [`get_matrix`](@ref)
"""
abstract type AbstractColoringResult{partition,symmetric,decompression,M<:AbstractMatrix} end

"""
    get_matrix(result::AbstractColoringResult)

Return the matrix that was colored.
"""
function get_matrix end

"""
    column_colors(result::AbstractColoringResult)

Return a vector `color` of integer colors, one for each column of the colored matrix.
"""
function column_colors end

"""
    row_colors(result::AbstractColoringResult)

Return a vector `color` of integer colors, one for each row of the colored matrix.
"""
function row_colors end

"""
    column_groups(result::AbstractColoringResult)

Return a vector `group` such that for every color `c`, `group[c]` contains the indices of all columns that are colored with `c`.
"""
function column_groups end

"""
    row_groups(result::AbstractColoringResult)

Return a vector `group` such that for every color `c`, `group[c]` contains the indices of all rows that are colored with `c`.
"""
function row_groups end

get_matrix(result::AbstractColoringResult) = result.matrix

column_colors(result::AbstractColoringResult{:column}) = result.color
column_groups(result::AbstractColoringResult{:column}) = result.group

row_colors(result::AbstractColoringResult{:row}) = result.color
row_groups(result::AbstractColoringResult{:row}) = result.group

## Concrete subtypes

"""
    group_by_color(color::Vector{Int})

Create `group::Vector{Vector{Int}}` such that `i ∈ group[c]` iff `color[i] == c`.

Assumes the colors are contiguously numbered from `1` to some `cmax`.
"""
function group_by_color(color::AbstractVector{<:Integer})
    cmin, cmax = extrema(color)
    @assert cmin == 1
    group = [Int[] for c in 1:cmax]
    for (k, c) in enumerate(color)
        push!(group[c], k)
    end
    return group
end

struct SimpleColoringResult{partition,symmetric,M} <:
       AbstractColoringResult{partition,symmetric,:direct,M}
    matrix::M
    color::Vector{Int}
    group::Vector{Vector{Int}}
end

function SimpleColoringResult{partition,symmetric}(
    matrix::M, color::Vector{Int}
) where {partition,symmetric,M}
    return SimpleColoringResult{partition,symmetric,M}(matrix, color, group_by_color(color))
end

struct SparseColoringResult{partition,symmetric,M} <:
       AbstractColoringResult{partition,symmetric,:direct,M}
    matrix::M
    color::Vector{Int}
    group::Vector{Vector{Int}}
    compressed_indices::Vector{Int}
end

function SparseColoringResult{partition,symmetric}(
    matrix::M, color::Vector{Int}, compressed_indices::Vector{Int}
) where {partition,symmetric,M}
    return SparseColoringResult{partition,symmetric,M}(
        matrix, color, group_by_color(color), compressed_indices
    )
end