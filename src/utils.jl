"""
utils.jl defines utility methods.

------------------------------------------------------------------------------
COPYRIGHT/LICENSE. This file is part of the XYZ package. It is subject to
the license terms in the LICENSE file found in the top-level directory of
this distribution. No part of the XYZ package, including this file, may be
copied, modified, propagated, or distributed except according to the terms
contained in the LICENSE file.
------------------------------------------------------------------------------
"""
# --- Exports

export construct_ipc_url

# --- Method definitions

"""
    construct_ipc_url(ipc_dir::String, ipc_name::String)

Construct IPC URL from `ipc_dir` and `ipc_name`.
"""
function construct_ipc_url(ipc_dir::String, ipc_name::String)
    if occursin("ipc://", ipc_dir)
        if !startswith(ipc_dir, "ipc://")
            message = """Invalid `ipc_dir` "$(ipc_dir)"."""
            throw(ArgumentError(message))
        end
    elseif !startswith(ipc_dir, "ipc://")
        ipc_dir = "ipc://" * ipc_dir
    end

    return joinpath(ipc_dir, ipc_name)
end
