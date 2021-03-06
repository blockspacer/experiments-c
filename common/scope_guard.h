#pragma once

#include <utility>

/// A lightweight scope guard implementation.
template <class Fun>
class scope_guard {

    scope_guard() = delete;
    scope_guard(const scope_guard&) = delete;
    scope_guard& operator=(const scope_guard&) = delete;

public:

    scope_guard(Fun f) : fun_(std::move(f)), enabled_(true) {}

    scope_guard(scope_guard&& other)
            : fun_(std::move(other.fun_)), enabled_(other.enabled_) {
        other.enabled_ = false;
    }

    ~scope_guard() {
        if (enabled_) fun_();
    }

    /// Disables this guard, i.e., the guard does not
    /// run its cleanup code as it goes out of scope.
    inline void disable() { enabled_ = false; }

private:

    Fun fun_;
    bool enabled_;

};

/// Creates a guard that executes `f` as soon as it goes out of scope.
/// @relates scope_guard
template <class Fun>
scope_guard<Fun> make_scope_guard(Fun f) {
    return {std::move(f)};
}