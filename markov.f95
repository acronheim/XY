module markov 
  use constants
  implicit none
  private
  public :: gen_config

contains
  subroutine gen_config(S,dE,p)
    integer, intent(inout) :: S(:,:)
    real(dp), intent(out) :: dE
    real(dp), intent(in) :: p
    integer :: i, j, S_tmp, s_cl, s_add, C_idx(N,2), x(2), nn(4,2)
    real(dp) :: r

    ! initialize variables 
    dE = 0._dp ! init dE
    s_cl = 1 ! number of spins in cluster
    s_add = 1 ! number of spins added to cluster
    C_idx = 0 ! initialize cluster 

    call random_spin(x) ! start cluster by choosing 1 spin
    C_idx(1,:) = x ! init array that holds indices of all spins in cluster

    do while (s_add /= 0)
      s_add = 0
      ! pick a spin x in the cluster
      ! here we need to keep track of the boundary 
      do i = 1,s_cl
        x = C_idx(i,:)
        nn = nn_idx(x) ! get nearest neighbors of spin x
        S_tmp = S(x(1),x(2)) ! get spin
        
        ! iterate over neighbors of x
        do j = 1,4 
          if (S(nn(j,1),nn(j,2))==S_tmp) then 
            call random_number(r)
            if (r<p) then ! segfault occurs here.. 
              s_cl = s_cl+1
              s_add = s_add+1
              C_idx(s_cl,:) = nn(j,:) ! add spin to cluster with probability p
            endif
          endif
        enddo
      enddo
      
      S(x(1),x(2)) = -S(x(1),x(2)) ! flip spin so it's not visited again
    enddo 
  end subroutine

  subroutine random_spin(x)
    ! returns index of randomly picked spin
    integer, intent(out) :: x(:)
    real(dp) :: u(2)

    call random_number(u)
    u = L*u + 0.5_dp
    x = nint(u) ! index of spin to flip
    x = x + 1 ! adjust for zero padding
  end subroutine

  function nn_idx(x)
    ! returns indices of nearest neighbors of x_ij
    integer, intent(in) :: x(2)
    integer :: nn_idx(4,2)

    nn_idx(1,:) = x + [1,0] 
    nn_idx(2,:) = x + [0,1] 
    nn_idx(3,:) = x - [1,0] 
    nn_idx(4,:) = x - [0,1] 
  end function
end module
