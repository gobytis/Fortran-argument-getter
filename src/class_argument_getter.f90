!> コマンド ライン引数を取得するクラスです。
module class_argument_getter
    use, intrinsic :: iso_fortran_env
    implicit none
    
    private
    
    !> コマンド ライン引数を表す構造体です。
    type, private :: command_line_argument
        character(:), private, allocatable :: value
    end type

    
    !> コマンド ライン引数を取得するクラスです。
    type, public :: argument_getter
        !> コマンド ライン引数を取得していれば true、そうでなければ false
        logical, private :: has_values = .false.
        !> コマンド ライン引数
        type(command_line_argument), private, allocatable :: value(:)

        contains

        procedure, private, pass :: get_all_command_line_arguments
        procedure, public, pass :: get
        procedure, public, pass :: get_size
        procedure, public, pass :: to_int32
        procedure, public, pass :: to_int64
        procedure, public, pass :: to_real32
        procedure, public, pass :: to_real64
    end type


    contains


    !> i 番目のコマンド ライン引数を返します。戻り値の型は character です。
    !
    function get(this, i) result(arg)
        ! 引数
        !> この手続きを実行するインスタンス (指定不要)
        class(argument_getter), intent(inout) :: this
        !> コマンド ライン引数の順番 (1 始まり、int32)
        integer(int32), intent(in) :: i
        ! 戻り値
        !> i 番目のコマンド ライン引数
        character(:), allocatable :: arg

        ! コマンド ライン引数を取得していなければ、コマンド ライン引数を全て取得します。
        if(.not. this%has_values) then
            call this%get_all_command_line_arguments()
        end if

        arg = this%value(i)%value
    end function


    !> コマンド ライン引数の個数を返します。
    function get_size(this) result(number_of_args)
        ! 引数
        !> この手続きを実行するインスタンス (指定不要)
        class(argument_getter), intent(inout) :: this
        ! 戻り値
        !> コマンド ライン引数の個数
        integer(int32) number_of_args

        ! コマンド ライン引数を取得していなければ、コマンド ライン引数を全て取得します。
        if(.not. this%has_values) then
            call this%get_all_command_line_arguments()
        end if

        number_of_args = size(this%value)
    end function


    !> 指定されているコマンド ライン引数を全て取得します。
    subroutine get_all_command_line_arguments(this)
        ! 引数
        !> この手続きを実行するインスタンス (指定不要)
        class(argument_getter), intent(inout) :: this
        !> コマンド ライン引数
        character(:), allocatable :: arg
        
        ! コマンド ライン引数の個数
        integer(int32) number_of_args
        ! コマンド ライン引数の文字列長を格納する配列
        integer(int32) length
        ! コマンド ライン引数取得時の状態
        integer(int32) status
        ! ループ カウンタ
        integer(int32) i
        
        ! コマンド ライン引数の個数を取得します。
        number_of_args = command_argument_count()
        
        ! コマンド ライン引数を格納する配列を生成します。
        allocate(this%value(number_of_args))
        
        do i = 1, number_of_args
            ! i 番目のコマンド ライン引数の長さを取得します。
            call get_command_argument(i, length=length, status=status)
            
            ! コマンド ライン引数の取得に失敗すれば、プログラムを終了します。
            if (status /= 0) then
                write(error_unit, *) "ERROR: Command line argument retrieval failed."
                write(error_unit, *) "Program ended."
                stop
            end if
            
            ! i 番目のコマンド ライン引数を取得します。
            allocate(character(length) :: arg)
            call get_command_argument(i, arg, status=status)
            
            ! コマンド ライン引数の取得に失敗すれば、プログラムを終了します。
            if (status /= 0) then
                write(error_unit, *) "ERROR: Command line argument retrieval failed."
                write(error_unit, *) "Program ended."
                stop
            end if

            ! コマンド ライン引数を格納します。
            this%value(i)%value = arg
            
            deallocate(arg)
        end do

        this%has_values = .true.
    end subroutine


    !> i 番目のコマンド ライン引数を int32 に変換します。
    function to_int32(this, i) result(output_integer)
        ! 引数
        !> この手続きを実行するインスタンス (指定不要)
        class(argument_getter), intent(inout) :: this
        !> int32 に変換したいコマンド ライン引数のインデックス
        integer(int32), intent(in) :: i
        ! 戻り値
        !> int32 の整数
        integer(int32) output_integer
        ! iostat 指定子
        integer(int32) iostat

        ! コマンド ライン引数を取得していなければ、コマンド ライン引数を全て取得します。
        if(.not. this%has_values) then
            call this%get_all_command_line_arguments()
        end if

        ! コマンド ライン引数を int32 に変換します。
        read(this%value(i)%value, *, iostat=iostat) output_integer

        ! 変換にエラーがあればプログラムを終了します。
        if(iostat > 0) then
            write(error_unit, *) "ERROR: An argument, ", this%value(i)%value, ", can not be converted into int32."
            write(error_unit, *) "Program ended."
            error stop
        end if
    end function


    !> i 番目のコマンド ライン引数を int64 に変換します。
    function to_int64(this, i) result(output_integer)
        ! 引数
        !> この手続きを実行するインスタンス (指定不要)
        class(argument_getter), intent(inout) :: this
        !> int64 に変換したいコマンド ライン引数のインデックス
        integer(int64), intent(in) :: i
        ! 戻り値
        !> int64 の整数
        integer(int64) output_integer
        ! iostat 指定子
        integer(int64) iostat

        ! コマンド ライン引数を取得していなければ、コマンド ライン引数を全て取得します。
        if(.not. this%has_values) then
            call this%get_all_command_line_arguments()
        end if

        ! コマンド ライン引数を int32 に変換します。
        read(this%value(i)%value, *, iostat=iostat) output_integer

        ! 変換にエラーがあればプログラムを終了します。
        if(iostat > 0) then
            write(error_unit, *) "ERROR: An argument, ", this%value(i)%value, ", can not converted into int64."
            write(error_unit, *) "Program ended."
            error stop
        end if
    end function


    !> i 番目のコマンド ライン引数を real32 に変換します。
    function to_real32(this, i) result(output_real_value)
        ! 引数
        !> この手続きを実行するインスタンス (指定不要)
        class(argument_getter), intent(inout) :: this
        !> real32 に変換したいコマンド ライン引数のインデックス
        integer(int32), intent(in) :: i
        ! 戻り値
        !> real32 の実数
        real(real32) output_real_value
        ! iostat 指定子
        integer(int32) iostat

        ! コマンド ライン引数を取得していなければ、コマンド ライン引数を全て取得します。
        if(.not. this%has_values) then
            call this%get_all_command_line_arguments()
        end if

        ! コマンド ライン引数を real64 に変換します。
        read(this%value(i)%value, *, iostat=iostat) output_real_value

        ! 変換にエラーがあればプログラムを終了します。
        if(iostat > 0) then
            write(error_unit, *) "ERROR: An argument, ", this%value(i)%value, ", can not be converted into real32."
            write(error_unit, *) "Program ended."
            error stop
        end if
    end function


    !> i 番目のコマンド ライン引数を real64 に変換します。
    function to_real64(this, i) result(output_real_value)
        ! 引数
        !> この手続きを実行するインスタンス (指定不要)
        class(argument_getter), intent(inout) :: this
        !> real64 に変換したいコマンド ライン引数のインデックス
        integer(int32), intent(in) :: i
        ! 戻り値
        !> real64 の実数
        real(real64) output_real_value
        ! iostat 指定子
        integer(int32) iostat

        ! コマンド ライン引数を取得していなければ、コマンド ライン引数を全て取得します。
        if(.not. this%has_values) then
            call this%get_all_command_line_arguments()
        end if

        ! コマンド ライン引数を real64 に変換します。
        read(this%value(i)%value, *, iostat=iostat) output_real_value

        ! 変換にエラーがあればプログラムを終了します。
        if(iostat > 0) then
            write(error_unit, *) "ERROR: An argument, ", this%value(i)%value, ", can not be converted into real64."
            write(error_unit, *) "Program ended."
            error stop
        end if
    end function
end module
